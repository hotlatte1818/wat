      subroutine transfer
      
!!    ~ ~ ~ PURPOSE ~ ~ ~
!!    this subroutine transfers water

!!    ~ ~ ~ INCOMING VARIABLES ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    icodes(:)   |none          |routing command code:
!!                               |0 = finish       9 = save
!!                               |1 = subbasin    10 = recday
!!                               |2 = route       11 = reccnst
!!                               |3 = routres     12 = structure
!!                               |4 = transfer    13 = 
!!                               |5 = add         14 = saveconc
!!                               |6 = rechour     15 = 
!!                               |7 = recmon      16 = autocal
!!                               |8 = recyear
!!    ihout       |none          |water source type:
!!                               |1 reach
!!                               |2 reservoir
!!    ihouts(:)   |none          |For ICODES equal to
!!                               |0: not used
!!                               |1,2,3,5,6,7,8,10,11: hydrograph storage
!!                               |                     location number
!!                               |4: water source type
!!                               |   (1=reach)
!!                               |   (2=reservoir)
!!                               |9: hydrograph storage location of data to
!!                               |   be printed to event file
!!                               |14:hydrograph storage location of data to
!!                               |   be printed to saveconc file
!!    inum1       |none          |reach or reservoir # from which water is
!!                               |removed
!!    inum1s(:)   |none          |For ICODES equal to
!!                               |0: not used
!!                               |1: subbasin number
!!                               |2: reach number
!!                               |3: reservoir number
!!                               |4: reach or res # flow is diverted from
!!                               |5: hydrograph storage location of 1st
!!                               |   dataset to be added
!!                               |6,7,8,9,10,11,14: file number
!!    inum2       |none          |water destination type:
!!                               |1 reach
!!                               |2 reservoir
!!    inum3       |none          |reach or reservoir # to which water is
!!                               |added
!!    inum4       |none          |rule governing transfer of water
!!                               |1 fraction of water in source transferred
!!                               |2 minimum volume (res) or flow (rch) left
!!                               |3 exact amount transferred
!!    mhyd        |none          |maximum number of hydrographs
!!    mvaro       |none          |max number of variables routed through the
!!                               |reach
!!    rchdy(2,:)  |m^3/s         |flow out of reach on day
!!    rchdy(6,:)  |metric tons   |sediment transported out of reach on day
!!    rchdy(9,:)  |kg N          |organic N transported out of reach on day
!!    rchdy(11,:) |kg P          |organic P transported out of reach on day
!!    rchdy(13,:) |kg N          |nitrate transported out of reach on day
!!    rchdy(15,:) |kg N          |ammonia transported out of reach on day
!!    rchdy(17,:) |kg N          |nitrite transported out of reach on day
!!    rchdy(19,:) |kg P          |soluble P transported out of reach on day
!!    rchdy(21,:) |kg chla       |chlorophyll-a transported out of reach on day
!!    rchdy(23,:) |kg O2         |CBOD transported out of reach on day
!!    rchdy(25,:) |kg O2         |dissolved oxygen transported out of reach on
!!                               |day
!!    rchdy(27,:) |mg pst        |soluble pesticide transported out of reach on
!!                               |day
!!    rchdy(29,:) |mg pst        |sorbed pesticide transported out of reach on
!!                               |day
!!    rchdy(38,:) |kg bact       |persistent bacteria transported out of reach
!!                               |on day
!!    rchdy(39,:) |kg bact       |less persistent bacteria transported out of
!!                               |reach on day
!!    rchstor(:)  |m^3 H2O       |water stored in reach
!!    res_vol(:)  |m^3 H2O       |reservoir volume
!!    rnum1       |m^3 H2O       |amount of water transferred
!!    varoute(:,:)|varies        |routing storage array
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ OUTGOING VARIABLES ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    rchdy(2,:)  |m^3/s         |flow out of reach on day
!!    rchdy(6,:)  |metric tons   |sediment transported out of reach on day
!!    rchdy(9,:)  |kg N          |organic N transported out of reach on day
!!    rchdy(11,:) |kg P          |organic P transported out of reach on day
!!    rchdy(13,:) |kg N          |nitrate transported out of reach on day
!!    rchdy(15,:) |kg N          |ammonia transported out of reach on day
!!    rchdy(17,:) |kg N          |nitrite transported out of reach on day
!!    rchdy(19,:) |kg P          |soluble P transported out of reach on day
!!    rchdy(21,:) |kg chla       |chlorophyll-a transported out of reach on day
!!    rchdy(23,:) |kg O2         |CBOD transported out of reach on day
!!    rchdy(25,:) |kg O2         |dissolved oxygen transported out of reach on
!!                               |day
!!    rchdy(27,:) |mg pst        |soluble pesticide transported out of reach on
!!                               |day
!!    rchdy(29,:) |mg pst        |sorbed pesticide transported out of reach on
!!                               |day
!!    rchdy(38,:) |kg bact       |persistent bacteria transported out of reach
!!                               |on day
!!    rchdy(39,:) |kg bact       |less persistent bacteria transported out of
!!                               |reach on day
!!    rchstor(:)  |m^3 H2O       |water stored in reach
!!    res_vol(:)  |m^3 H2O       |reservoir volume
!!    varoute(:,:)|varies        |routing storage array
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ LOCAL DEFINITIONS ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    ii          |none          |counter
!!    k           |none          |counter
!!    ratio       |none          |fraction of reach outflow diverted
!!    tranmx      |m^3 H2O       |maximum amount of water to be transferred
!!    volum       |m^3 H2O       |volume of water in source
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ SUBROUTINES/FUNCTIONS CALLED ~ ~ ~

!!    ~ ~ ~ ~ ~ ~ END SPECIFICATIONS ~ ~ ~ ~ ~ ~
      use parm

      integer :: k, ii
      real :: volum, tranmx, ratio,vtot

      nhyd_tr = ih_tran(inum5)
      vartran(:,inum3) = 0.

!! check beg/end months summer or winter
      if (mo_transb(inum5) < mo_transe(inum5)) then
        if (i_mo < mo_transb(inum5) .or. i_mo > mo_transe(inum5)) return
      else 
        if (i_mo > mo_transe(inum5) .and. i_mo < mo_transb(inum5))return
      end if
!! compute volume of water in source
      volum = 0.
      if (ihout == 2) then
        volum = res_vol(inum1) + varoute(2,nhyd_tr) 
      else
        volum = rchdy(2,inum1) * 86400.
      end if
      if (volum <= 0.) return

      
!! compute maximum amount of water allowed to be transferred
      tranmx = 0.
      select case (inum4)
        case (1)     !! transfer fraction of water in source
          tranmx = volum * rnum1
        case (2)     !! leave minimum volume or flow
          tranmx = volum - rnum1 * 86400.
          if (tranmx < 0.) tranmx = 0.
        case (3)     !! transfer volume specified
          tranmx = rnum1 * 86400.
          if (tranmx > volum) tranmx = volum
      end select
 
      if (tranmx > 0.) then

        !! Source is a reservoir 
        if (ihout == 2) then
          ratio = 1. - tranmx / volum
          ratio1 = 1.- ratio
          res_vol(inum1) = res_vol(inum1) * ratio          !!|m^3 H2O      |water
          res_nh3(inum1) = res_nh3(inum1) * ratio          !!|kg N          |amount of ammonia in reservoir
          res_no2(inum1) = res_no2(inum1) * ratio          !!|kg N          |amount of nitrite in reservoir
          res_no3(inum1) = res_no3(inum1) * ratio          !!|kg N          |amount of nitrate in reservoir
          res_orgn(inum1)= res_orgn(inum1)* ratio          !!|kg N          |amount of organic N in reservoir
          res_orgp(inum1)= res_orgp(inum1)* ratio          !!|kg P          |amount of organic P in reservoir
          res_solp(inum1)= res_solp(inum1)* ratio          !!|kg P          |amount of soluble P in reservior
          res_chla(inum1)= res_chla(inum1)* ratio          !!|kg chl-a      |amount of chlorophyll-a leaving reaservoir
          do ii = 2, mvaro
              varoute(ii,nhyd_tr) = varoute(ii,nhyd_tr) * ratio
          end do

          !!save vartran to add in rchinit/resinit 
          vartran(2,inum3) = tranmx
          vartran(3,inum3) = res_sed(inum1) * tranmx 
          vartran(4,inum3) = (res_orgn(inum1) + varoute(4,nhyd_tr)) 
     &                        / ratio * ratio1 
          vartran(5,inum3) = (res_orgp(inum1) + varoute(5,nhyd_tr)) 
     &                        / ratio * ratio1 
          vartran(6,inum3) = (res_no3(inum1) + varoute(6,nhyd_tr)) 
     &                        / ratio * ratio1 
          vartran(7,inum3) = (res_solp(inum1) + varoute(7,nhyd_tr)) 
     &                        / ratio * ratio1 

          vartran(11,inum3) = lkpst_conc(inum1) * tranmx  !mg pesticide 
          vartran(13,inum3) = (res_chla(inum1) + varoute(13,nhyd_tr)) 
     &                        / ratio * ratio1 

         
        else
        !! Source is a reach    
          xx = tranmx
!          if (xx > rchstor(inum1)) then
!            xx = tranmx - rchstor(inum1)
!            rchstor(inum1) = 0.
!          else
!            rchstor(inum1) = rchstor(inum1) - xx
!            xx = 0.
!          end if

          if (xx > varoute(2,nhyd_tr)) then
            xx = tranmx - varoute(2,nhyd_tr)
            varoute(2,nhyd_tr) = 0.
          else
            varoute(2,nhyd_tr) = varoute(2,nhyd_tr) - xx
            xx = 0.
          end if
          
          ratio = 0.
          if (rchdy(2,inum1) > 1.e-6) then
            xx = tranmx - xx
            ratio = 1. - xx / (rchdy(2,inum1) * 86400.)
          end if
          
          ratio1 = 1. - ratio
          rchmono(2,inum1) = rchmono(2,inum1) - rchdy(2,inum1) * ratio1  !!flow out
          rchmono(6,inum1) = rchmono(6,inum1) - rchdy(8,inum1) * ratio1  !!org N out
          rchmono(9,inum1) = rchmono(9,inum1) - rchdy(11,inum1) * ratio1 !!org P out
          rchmono(11,inum1)=rchmono(11,inum1) - rchdy(4,inum1) * ratio1  !!transmission losses from reach
          rchmono(13,inum1)=rchmono(13,inum1) - rchdy(41,inum1) * ratio1 !!conservative metal #2 out
          rchmono(15,inum1)=rchmono(15,inum1) - rchdy(12,inum1) * ratio1 !!nitrate transported into reach
          rchmono(17,inum1)=rchmono(17,inum1) - rchdy(18,inum1) * ratio1 !!soluble P transported into reach
          rchmono(19,inum1)=rchmono(19,inum1) - rchdy(26,inum1) * ratio1 !!soluble pesticide transported into reach
          rchmono(21,inum1)=rchmono(21,inum1) - rchdy(28,inum1) * ratio1 !!sorbed pesticide transported into reach
          rchmono(23,inum1)=rchmono(23,inum1) - rchdy(30,inum1) * ratio1 !!amount of pesticide lost through reactions
          rchmono(25,inum1)=rchmono(25,inum1) - rchdy(32,inum1) * ratio1 !!amount of pesticide settling out of reach
          rchmono(27,inum1)=rchmono(27,inum1) - rchdy(34,inum1) * ratio1 !!amount of pesticide diffusing from reach
          rchmono(29,inum1)=rchmono(29,inum1) - rchdy(36,inum1) * ratio1 !!amount of pesticide in sediment layer
          rchmono(38,inum1)=rchmono(38,inum1) - rchdy(24,inum1) * ratio1 !!dissolved oxygen transported into reach
          rchmono(39,inum1)=rchmono(39,inum1) - rchdy(25,inum1) * ratio1 !!dissolved osygen transported out of reach
          rchmono(40,inum1)=rchmono(40,inum1) - rchdy(38,inum1) * ratio1 !!persistent bacteria transported out of reach
          rchmono(41,inum1)=rchmono(41,inum1) - rchdy(39,inum1) * ratio1 !!less persistent bacteria transported out of reach
          
          rchdy(2,inum1) = rchdy(2,inum1) * ratio
          rchdy(8,inum1) = rchdy(8,inum1) * ratio
          rchdy(11,inum1) = rchdy(11,inum1) * ratio
          rchdy(4,inum1) = rchdy(4,inum1) * ratio
          rchdy(41,inum1) = rchdy(41,inum1) * ratio
          rchdy(12,inum1) = rchdy(12,inum1) * ratio
          rchdy(18,inum1) = rchdy(18,inum1) * ratio
          rchdy(26,inum1) = rchdy(26,inum1) * ratio
          rchdy(28,inum1) = rchdy(28,inum1) * ratio
          rchdy(30,inum1) = rchdy(30,inum1) * ratio
          rchdy(32,inum1) = rchdy(32,inum1) * ratio
          rchdy(34,inum1) = rchdy(34,inum1) * ratio
          rchdy(36,inum1) = rchdy(36,inum1) * ratio
          rchdy(24,inum1) = rchdy(24,inum1) * ratio
          rchdy(25,inum1) = rchdy(25,inum1) * ratio
          rchdy(38,inum1) = rchdy(38,inum1) * ratio
          rchdy(39,inum1) = rchdy(39,inum1) * ratio
        
          !!subract from source
          do ii = 3, mvaro
            varoute(ii,nhyd_tr) = varoute(ii,nhyd_tr) * ratio
          end do
          !!save vartran to add in rchinit
          if (ratio < 0.01) then
            vartran(2,inum3) = 0.
            ratio1 = 0.
          else
            vartran(2,inum3) = varoute(2,nhyd_tr) / ratio * ratio1
          end if
          do ii = 3, mvaro
            vartran(ii,inum3) = varoute(ii,nhyd_tr) * ratio1
          end do
        end if      
      end if

      return
      end