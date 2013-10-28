#!/bin/bash

### spkunmerge.bash:  extract each body from SP-Kernel(s)
###
### Usage (BASH):
###
###   [NOCLEANUP=yes] \
###   spkunmerge [naif0010.tls] [kernels/plu017.bsp[ anotherSPK.bsp[ ...]]]
###
### e.g. Creates plu017_901.bsp, plu017_902.bsp, plu017_903.bsp and plu017_099.bsp
###
### N.B.
###
###   Overwrites new SPKs in $PWD (Present Working Directory) e.g.
###     ./plu017_901.bsp
###     ./plu017_902.bsp
###     ./plu017_903.bsp
###     ./plu017_999.bsp
###
###   A Leapsecond-Kernel is required; defaults to ./naif0010.tls
###
###   Overwrites SPKMERGE command files in $PWD e.g.
###     ./plu017_9xx.spkmerge
###   then deletes them unless NOCLEANUP environment variable is
###   non-null

########################################################################

### Assume default LSK
lsk="naif0010.tls"

### Loop over command-line arguments

while [ $# -gt 0 ] ; do

  ### Copy first argument locally, then delete from list of arguments
  one="$1"
  shift

  ### Check if argument is a Leapsecond-Kernel i.e. ends in .tls;
  ### - if it is, save its filename and continue with next command-line argument
  onenotls="${one%.tls}"
  [ "$one" != "$onenotls" ] && lsk="$one" && continue || true

  ### Check if argument is likely a SP-Kernel i.e. ends in .bsp; skip if not
  onepfx="${one%.bsp}"
  [ "$one" == "$onepfx" ] && ( echo "Skipping $one ..." || true ) && continue \
  || true

  ### Strip any directory prefix
  onepfx="`basename \"$onepfx\"`"

  ### Check if current LSK is readable
  [ -r "$lsk" ] || ( echo "Invalid LSK; skipping $one ..." && false ) || continue

  ### Use BRIEF (+ SED + GREP) to list body IDs, pipe to while
  brief -n -t -c "$one" \
  | sed '1,/^--*  *--*  *--* *$/d' \
  | grep '^[-0-9][0-9]* w[.]r[.]t[.] ' \
  | while read bodyid wrt xxx ; do

      ### Skip if balance of line is empty
      [ "$xxx" ] || continue

      ### To here, we are looping over one body ID in the input SPK:
      ### - build filename prefix and filenames based on body ID, e.g.: 
      ###   - prefix (from above):     kernels/plu017.bsp => plu017_901
      ###   - SPKMERGE command file:   plu017_901.spkmerge
      ###   - output SPK filename:     plu017_901.bsp
      pfx="${onepfx}_${bodyid}"
      onespkmerge="${pfx}.spkmerge"
      onenewbsp="${pfx}.bsp"

      ### Create SPKMERGE command file to extract $bodyid from input SPK
      ### - A log of these commands will be saved in output SPK comments;
      ###   the command file will be deleted below
      cat << EoF > "${onespkmerge}"
      leapseconds_kernel  = ${lsk}
      spk_kernel = ${onenewbsp}
        source_spk_kernel  = ${one}
          bodies           = $bodyid
          include_comments = yes
EoF

      ### Remove any existing file with the same name as the output SPK, and
      ### then run SPKMERGE on command file to create the output SPK
      rm -f "${onenewbsp}" || true
      spkmerge "${onespkmerge}"

      ### Clean up by removing SPKMERGE command file unless NOCLEANUP envvar
      ### exists and is not empty
      [ "$NOCLEANUP" ] || rm -f "${onespkmerge}" || true

    ### End of inner while loop over body IDs; use grep to compress standard
    ### output of SPKMERGE
    done | grep '[^ ]'

### End of outer while loop over command line arguments
done
