   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.6 (r4159) - 21 Sep 2011 10:11
   !
   !  Differentiation of block_res in forward (tangent) mode:
   !   variations   of useful results: *(*flowdoms.x) *(*flowdoms.w)
   !                *(*flowdoms.dw) *(*bcdata.f) pointref costfuncmat
   !                moment lift cforce drag force cd cl cmoment
   !   with respect to varying inputs: *(*flowdoms.x) *(*flowdoms.w)
   !                pointref surfaceref lengthref machgrid mach alpha
   !                beta
   !   RW status of diff variables: *(*flowdoms.x):in-out *(*flowdoms.w):in-out
   !                *(*flowdoms.dw):out *(*bcdata.f):out pointref:in-out
   !                surfaceref:in lengthref:in machgrid:in mach:in
   !                costfuncmat:out moment:out lift:out alpha:in cforce:out
   !                drag:out force:out cd:out beta:in cl:out cmoment:out
   !   Plus diff mem management of: flowdoms:in *flowdoms.x:in *flowdoms.w:in
   !                *flowdoms.dw:in rev:in dtl:in bvtj1:in bvtj2:in
   !                p:in sfacei:in sfacej:in s:in gamma:in sfacek:in
   !                bmtk1:in bmtk2:in rlv:in bvtk1:in bvtk2:in xold:in
   !                vol:in d2wall:in bmti1:in bmti2:in si:in sj:in
   !                sk:in bvti1:in bvti2:in fw:in rotmatrixi:in rotmatrixj:in
   !                rotmatrixk:in bmtj1:in bmtj2:in viscsubface:in
   !                *viscsubface.tau:in *viscsubface.q:in *viscsubface.utau:in
   !                bcdata:in *bcdata.norm:in *bcdata.rface:in *bcdata.f:in
   !                *bcdata.uslip:in *bcdata.tns_wall:in radi:in radj:in
   !                radk:in winf:in coeftime:in (global)cphint:in
   ! This is a super-combined function that combines the original
   ! functionality of: 
   ! Pressure Computation
   ! timeStep
   ! applyAllBCs
   ! initRes
   ! residual 
   ! The real difference between this and the original modules is that it
   ! it only operates on a single block at a time and as such the nominal
   ! block/sps loop is outside the calculation. This routine is suitable
   ! for forward mode AD with Tapenade
   SUBROUTINE BLOCK_RES_D(nn, sps, usespatial, useforces, alpha, alphad, &
   &  beta, betad, liftindex, force, forced, moment, momentd, lift, liftd, &
   &  drag, dragd, cforce, cforced, cmoment, cmomentd, cl, cld, cd, cdd)
   USE FLOWVARREFSTATE
   USE MONITOR
   USE BLOCKPOINTERS_D
   USE SECTION
   USE INPUTTIMESPECTRAL
   USE COSTFUNCTIONS
   USE INPUTPHYSICS
   USE ITERATION
   USE DIFFSIZES
   !  Hint: ISIZE1OFDrfbcdata should be the size of dimension 1 of array *bcdata
   IMPLICIT NONE
   ! Input Arguments:
   INTEGER(kind=inttype), INTENT(IN) :: nn, sps
   LOGICAL, INTENT(IN) :: usespatial, useforces
   REAL(kind=realtype), INTENT(IN) :: alpha, beta
   REAL(kind=realtype), INTENT(IN) :: alphad, betad
   INTEGER(kind=inttype), INTENT(IN) :: liftindex
   ! Output Arguments:
   REAL(kind=realtype), DIMENSION(3), INTENT(OUT) :: force, moment, &
   &  cforce, cmoment
   REAL(kind=realtype), DIMENSION(3), INTENT(OUT) :: forced, momentd, &
   &  cforced, cmomentd
   REAL(kind=realtype), INTENT(OUT) :: lift, drag, cl, cd
   REAL(kind=realtype), INTENT(OUT) :: liftd, dragd, cld, cdd
   ! Working Variables
   REAL(kind=realtype) :: gm1, v2, fact
   REAL(kind=realtype) :: v2d, factd
   INTEGER(kind=inttype) :: i, j, k, sps2, mm, l
   REAL(kind=realtype), DIMENSION(nsections) :: t
   REAL(kind=realtype), DIMENSION(nsections) :: td
   REAL(kind=realtype), DIMENSION(3) :: cfp, cfv, cmp, cmv
   REAL(kind=realtype), DIMENSION(3) :: cfpd, cfvd, cmpd, cmvd
   REAL(kind=realtype) :: yplusmax
   LOGICAL :: useoldcoor
   REAL(realtype) :: result1
   INTRINSIC MAX
   INTRINSIC REAL
   INTEGER :: ii1
   useoldcoor = .false.
   ! Set pointers to input/output variables
   wd => flowdomsd(nn, currentlevel, sps)%w
   w => flowdoms(nn, currentlevel, sps)%w
   dwd => flowdomsd(nn, 1, sps)%dw
   dw => flowdoms(nn, 1, sps)%dw
   xd => flowdomsd(nn, currentlevel, sps)%x
   x => flowdoms(nn, currentlevel, sps)%x
   ! ------------------------------------------------
   !        Additional 'Extra' Components
   ! ------------------------------------------------
   dragdirectiond = 0.0
   liftdirectiond = 0.0
   CALL ADJUSTINFLOWANGLE_D(alpha, alphad, beta, betad, liftindex)
   CALL REFERENCESTATE_D()
   CALL SETFLOWINFINITYSTATE_D()
   ! ------------------------------------------------
   !        Additional Spatial Components
   ! ------------------------------------------------
   IF (usespatial) THEN
   CALL XHALO_BLOCK_D()
   CALL METRIC_BLOCK_D()
   ! -------------------------------------
   ! These functions are required for TS
   ! --------------------------------------
   t = timeunsteadyrestart
   IF (equationmode .EQ. timespectral) THEN
   DO mm=1,nsections
   result1 = REAL(ntimeintervalsspectral, realtype)
   td(mm) = 0.0
   t(mm) = t(mm) + (sps-1)*sections(mm)%timeperiod/result1
   END DO
   END IF
   CALL GRIDVELOCITIESFINELEVEL_BLOCK_D(useoldcoor, t, sps)
   ! Required for TS
   CALL NORMALVELOCITIES_BLOCK_D(sps)
   ! Required for TS
   ELSE
   sfaceid = 0.0
   sfacejd = 0.0
   sd = 0.0
   sfacekd = 0.0
   vold = 0.0
   sid = 0.0
   sjd = 0.0
   skd = 0.0
   DO ii1=1,ISIZE1OFDrfbcdata
   bcdatad(ii1)%norm = 0.0
   END DO
   DO ii1=1,ISIZE1OFDrfbcdata
   bcdatad(ii1)%rface = 0.0
   END DO
   END IF
   ! ------------------------------------------------
   !        Normal Residual Computation
   ! ------------------------------------------------
   ! Compute the pressures
   gm1 = gammaconstant - one
   pd = 0.0
   ! Compute P 
   DO k=0,kb
   DO j=0,jb
   DO i=0,ib
   v2d = 2*w(i, j, k, ivx)*wd(i, j, k, ivx) + 2*w(i, j, k, ivy)*wd(&
   &          i, j, k, ivy) + 2*w(i, j, k, ivz)*wd(i, j, k, ivz)
   v2 = w(i, j, k, ivx)**2 + w(i, j, k, ivy)**2 + w(i, j, k, ivz)**&
   &          2
   pd(i, j, k) = gm1*(wd(i, j, k, irhoe)-half*(wd(i, j, k, irho)*v2&
   &          +w(i, j, k, irho)*v2d))
   p(i, j, k) = gm1*(w(i, j, k, irhoe)-half*w(i, j, k, irho)*v2)
   IF (p(i, j, k) .LT. 1.e-4_realType*pinfcorr) THEN
   pd(i, j, k) = 1.e-4_realType*pinfcorrd
   p(i, j, k) = 1.e-4_realType*pinfcorr
   ELSE
   p(i, j, k) = p(i, j, k)
   END IF
   END DO
   END DO
   END DO
   ! Compute Laminar/eddy viscosity if required
   CALL COMPUTELAMVISCOSITY_D()
   CALL COMPUTEEDDYVISCOSITY_D()
   !  Apply all BC's
   CALL APPLYALLBC_BLOCK_D(.true.)
   ! Compute skin_friction Velocity (only for wall Functions)
   CALL COMPUTEUTAU_BLOCK()
   ! Compute time step and spectral radius
   CALL TIMESTEP_BLOCK_D(.false.)
   ! -------------------------------
   ! The forward ADjoint is NOT currently setup for RANS equations
   !   if( equations == RANSEquations ) then
   !      ! Initialize only the Turblent Variables
   !      call initres_block(nt1MG, nMGVar,nn,sps) 
   !      call turbResidual_block
   !   endif
   ! -------------------------------  
   ! -------------------------------
   ! The forward ADjoint is NOT currently setup for TS adjoint
   ! Next initialize residual for flow variables. The is the only place
   ! where there is an n^2 dependance
   !   do sps2 = 1,nTimeIntervalsSpectral
   !      dw => flowDoms(nn, 1, sps2)%dw
   !      call initRes_block(1, nwf, nn, sps2)
   !   end do
   !   ! Reset dw pointer to sps instance
   !   dw => flowDoms(nn, 1, sps)%dw
   ! ---------------------------------
   ! This call replaces initRes for steady case. 
   dwd = 0.0
   dw = zero
   !  Actual residual calc
   CALL RESIDUAL_BLOCK_D()
   ! Divide through by the volume
   DO sps2=1,ntimeintervalsspectral
   ! Set dw and vol to looping sps2 instance
   dwd => flowdomsd(nn, 1, sps2)%dw
   dw => flowdoms(nn, 1, sps2)%dw
   vold => flowdomsd(nn, currentlevel, sps2)%vol
   vol => flowdoms(nn, currentlevel, sps2)%vol
   DO l=1,nw
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = dwd(i, j, k, l)/vol(i, j, k)
   dw(i, j, k, l) = dw(i, j, k, l)/vol(i, j, k)
   END DO
   END DO
   END DO
   END DO
   END DO
   ! Reset dw and vol to sps instance
   dwd => flowdomsd(nn, 1, sps)%dw
   dw => flowdoms(nn, 1, sps)%dw
   vold => flowdomsd(nn, currentlevel, sps)%vol
   vol => flowdoms(nn, currentlevel, sps)%vol
   ! We are now done with the residuals, we move on to the forces and moments
   ! This routine compute Force, Moment, Lift, Drag, and the
   ! coefficients of the values
   IF (useforces) THEN
   CALL FORCESANDMOMENTS_D(cfp, cfpd, cfv, cfvd, cmp, cmpd, cmv, cmvd, &
   &                      yplusmax)
   ! Sum pressure and viscous contributions
   cforced = cfpd + cfvd
   cforce = cfp + cfv
   cmomentd = cmpd + cmvd
   cmoment = cmp + cmv
   ! Get Lift coef and Drag coef
   cdd = cforced(1)*dragdirection(1) + cforce(1)*dragdirectiond(1) + &
   &      cforced(2)*dragdirection(2) + cforce(2)*dragdirectiond(2) + &
   &      cforced(3)*dragdirection(3) + cforce(3)*dragdirectiond(3)
   cd = cforce(1)*dragdirection(1) + cforce(2)*dragdirection(2) + &
   &      cforce(3)*dragdirection(3)
   cld = cforced(1)*liftdirection(1) + cforce(1)*liftdirectiond(1) + &
   &      cforced(2)*liftdirection(2) + cforce(2)*liftdirectiond(2) + &
   &      cforced(3)*liftdirection(3) + cforce(3)*liftdirectiond(3)
   cl = cforce(1)*liftdirection(1) + cforce(2)*liftdirection(2) + &
   &      cforce(3)*liftdirection(3)
   ! Divide by fact to get the forces, Lift and Drag back
   factd = -(two*gammainf*machcoef**2*lref**2*(pinfd*surfaceref+pinf*&
   &      surfacerefd)/(gammainf*pinf*machcoef*machcoef*surfaceref*lref*lref&
   &      )**2)
   fact = two/(gammainf*pinf*machcoef*machcoef*surfaceref*lref*lref)
   forced = (cforced*fact-cforce*factd)/fact**2
   force = cforce/fact
   liftd = (cld*fact-cl*factd)/fact**2
   lift = cl/fact
   dragd = (cdd*fact-cd*factd)/fact**2
   drag = cd/fact
   ! Moment factor has an extra lengthRef
   factd = (factd*lengthref*lref-fact*lref*lengthrefd)/(lengthref*lref)&
   &      **2
   fact = fact/(lengthref*lref)
   momentd = (cmomentd*fact-cmoment*factd)/fact**2
   moment = cmoment/fact
   ELSE
   DO ii1=1,ISIZE1OFDrfbcdata
   bcdatad(ii1)%f = 0.0
   END DO
   momentd = 0.0
   liftd = 0.0
   cforced = 0.0
   dragd = 0.0
   forced = 0.0
   cdd = 0.0
   cld = 0.0
   cmomentd = 0.0
   END IF
   CALL GETCOSTFUNCMAT_D(alpha, alphad, beta, betad, liftindex)
   END SUBROUTINE BLOCK_RES_D
