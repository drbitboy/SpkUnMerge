SpkUnMerge
==========

BASH script to extract trajectories of each body in a NAIF/SPICE SPK to a separate SPK

See [[http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/ug/spkmerge.html]]

 spkunmerge.bash:  extract each body from SP-Kernel(s)

 Usage (BASH):

  NOCLEANUP=yes] \
   spkunmerge [naif0010.tls] [kernels/plu017.bsp[ anotherSPK.bsp[ ...]]]

 e.g. Creates plu017_901.bsp, plu017_902.bsp, plu017_903.bsp and plu017_099.bsp

 See http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/ug/spkmerge.html

 N.B.

   Overwrites new SPKs in $PWD (Present Working Directory) e.g.
     ./plu017_901.bsp
     ./plu017_902.bsp
     ./plu017_903.bsp
     ./plu017_999.bsp

   A Leapsecond-Kernel is required; defaults to ./naif0010.tls

   Overwrites SPKMERGE command files in $PWD e.g.
     ./plu017_9xx.spkmerge
   then deletes them unless NOCLEANUP environment variable is
   non-null
