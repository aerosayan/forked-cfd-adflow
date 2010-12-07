   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.4 (r3375) - 10 Feb 2010 15:08
   !
   !  Differentiation of bcfarfieldnkpc in reverse (adjoint) mode:
   !   gradient     of useful results: padj wadj
   !   with respect to varying inputs: padj wadj
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcFarfieldAdj.f90                               *
   !      * Author:        Edwin van der Weide                             *
   !      *                Seongim Choi,C.A.(Sandy) Mader                  *
   !      * Starting date: 03-21-2006                                      *
   !      * Last modified: 04-23-2008                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCFARFIELDNKPC_B(secondhalo, winfadj, pinfcorradj, wadj, &
   &  wadjb, padj, padjb, siadj, sjadj, skadj, normadj, rfaceadj, icell, &
   &  jcell, kcell, nn, level, sps, sps2)
   USE BLOCKPOINTERS, ONLY : nbocos, bctype
   USE INPUTTIMESPECTRAL
   USE BCTYPES
   USE CONSTANTS
   USE ITERATION
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcFarfieldAdj applies the farfield boundary condition to       *
   !      * subface nn of the block to which the pointers in blockPointers *
   !      * currently point.                                               *
   !      *                                                                *
   !      ******************************************************************
   !
   ! irho,ivx,ivy,ivz
   ! gammaInf, wInf, pInfCorr
   !nIntervalTimespectral
   !
   !      Subroutine arguments.
   !
   ! it's not needed anymore w/ normAdj
   INTEGER(kind=inttype) :: nn, level, sps, sps2
   !       integer(kind=intType), intent(in) :: icBeg, icEnd, jcBeg, jcEnd
   !       integer(kind=intType), intent(in) :: iOffset, jOffset
   INTEGER(kind=inttype) :: icell, jcell, kcell
   INTEGER(kind=inttype) :: isbeg, jsbeg, ksbeg, isend, jsend, ksend
   INTEGER(kind=inttype) :: ibbeg, jbbeg, kbbeg, ibend, jbend, kbend
   INTEGER(kind=inttype) :: icbeg, jcbeg, kcbeg, icend, jcend, kcend
   INTEGER(kind=inttype) :: ioffset, joffset, koffset
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2) :: rlvadj, revadj
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: rlvadj1, rlvadj2
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: revadj1, revadj2
   REAL(kind=realtype), DIMENSION(nw), INTENT(IN) :: winfadj
   !  real(kind=realType), dimension(-2:2,-2:2,-2:2,3), intent(in) :: &
   !       siAdj, sjAdj, skAdj
   REAL(kind=realtype), DIMENSION(-3:2, -3:2, -3:2, 3, &
   &  ntimeintervalsspectral), INTENT(IN) :: siadj, sjadj, skadj
   REAL(kind=realtype), DIMENSION(nbocos, -2:2, -2:2, 3, &
   &  ntimeintervalsspectral), INTENT(IN) :: normadj
   REAL(kind=realtype), DIMENSION(nbocos, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: rfaceadj
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2, nw, &
   &  ntimeintervalsspectral), INTENT(IN) :: wadj
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2, nw, &
   &  ntimeintervalsspectral) :: wadjb
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: padj
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral) :: padjb
   REAL(kind=realtype) :: pinfcorradj
   !logical, intent(in) :: secondHalo
   LOGICAL :: secondhalo
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, nw) :: wadj0, wadj1
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, nw) :: wadj0b, wadj1b
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, nw) :: wadj2, wadj3
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, nw) :: wadj2b, wadj3b
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: padj0, padj1
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: padj0b, padj1b
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: padj2, padj3
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: padj2b, padj3b
   !real(kind=realType), dimension(nBocos,-2:2,-2:2,3), intent(in) :: normAdj
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, l, ii, jj, nnbcs
   REAL(kind=realtype) :: nnx, nny, nnz
   REAL(kind=realtype) :: gm1, ovgm1, gm53, factk, ac1, ac2
   REAL(kind=realtype) :: ac1b, ac2b
   REAL(kind=realtype) :: r0, u0, v0, w0, qn0, vn0, c0, s0
   REAL(kind=realtype) :: re, ue, ve, we, qne, ce
   REAL(kind=realtype) :: reb, ueb, veb, web, qneb, ceb
   REAL(kind=realtype) :: qnf, cf, uf, vf, wf, sf, cc, qq
   REAL(kind=realtype) :: qnfb, cfb, ufb, vfb, wfb, sfb, ccb
   REAL(kind=realtype) :: rface
   LOGICAL :: computebc
   REAL(kind=realtype) :: tmp
   REAL(kind=realtype) :: tmp0
   INTEGER :: branch
   INTEGER :: ad_from
   INTEGER :: ad_to
   INTEGER :: ad_from0
   INTEGER :: ad_to0
   REAL(kind=realtype) :: tempb3
   REAL(kind=realtype) :: tempb2
   REAL(kind=realtype) :: tempb1
   REAL(kind=realtype) :: tempb0
   REAL(kind=realtype) :: tmpb
   REAL(kind=realtype) :: tmp0b
   REAL(kind=realtype) :: tempb
   INTRINSIC SQRT
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Some constants needed to compute the riemann invariants.
   gm1 = gammainf - one
   ovgm1 = one/gm1
   gm53 = gammainf - five*third
   factk = -(ovgm1*gm53)
   ! Compute the three velocity components, the speed of sound and
   ! the entropy of the free stream.
   r0 = one/winfadj(irho)
   u0 = winfadj(ivx)
   v0 = winfadj(ivy)
   w0 = winfadj(ivz)
   c0 = SQRT(gammainf*pinfcorradj*r0)
   s0 = winfadj(irho)**gammainf/pinfcorradj
   ! Loop over the boundary condition subfaces of this block.
   bocos:DO nnbcs=1,nbocos
   CALL PUSHINTEGER4ARRAY(kbend, inttype/4)
   CALL PUSHINTEGER4ARRAY(jbend, inttype/4)
   CALL PUSHINTEGER4ARRAY(ibend, inttype/4)
   CALL PUSHINTEGER4ARRAY(kbbeg, inttype/4)
   CALL PUSHINTEGER4ARRAY(jbbeg, inttype/4)
   CALL PUSHINTEGER4ARRAY(ibbeg, inttype/4)
   CALL PUSHINTEGER4ARRAY(ksend, inttype/4)
   CALL PUSHINTEGER4ARRAY(jsend, inttype/4)
   CALL PUSHINTEGER4ARRAY(isend, inttype/4)
   CALL PUSHINTEGER4ARRAY(ksbeg, inttype/4)
   CALL PUSHINTEGER4ARRAY(jsbeg, inttype/4)
   CALL PUSHINTEGER4ARRAY(isbeg, inttype/4)
   CALL CHECKOVERLAPNKPC(nnbcs, icell, jcell, kcell, isbeg, jsbeg, &
   &                       ksbeg, isend, jsend, ksend, ibbeg, jbbeg, kbbeg, &
   &                       ibend, jbend, kbend, computebc)
   IF (computebc) THEN
   ! Check for farfield boundary conditions.
   IF (bctype(nnbcs) .EQ. farfield) THEN
   CALL PUSHBOOLEAN(secondhalo)
   CALL PUSHINTEGER4ARRAY(jcend, inttype/4)
   CALL PUSHINTEGER4ARRAY(icend, inttype/4)
   CALL PUSHINTEGER4ARRAY(jcbeg, inttype/4)
   CALL PUSHINTEGER4ARRAY(icbeg, inttype/4)
   CALL PUSHINTEGER4ARRAY(joffset, inttype/4)
   CALL PUSHINTEGER4ARRAY(ioffset, inttype/4)
   CALL PUSHREAL8ARRAY(padj2, realtype*5**2/8)
   CALL PUSHREAL8ARRAY(padj1, realtype*5**2/8)
   CALL PUSHREAL8ARRAY(wadj2, realtype*5**2*nw/8)
   CALL PUSHREAL8ARRAY(wadj1, realtype*5**2*nw/8)
   CALL EXTRACTBCSTATESNKPC(nnbcs, wadj, padj, wadj0, wadj1, &
   &                              wadj2, wadj3, padj0, padj1, padj2, padj3, &
   &                              rlvadj, revadj, rlvadj1, rlvadj2, revadj1&
   &                              , revadj2, ioffset, joffset, koffset, &
   &                              icell, jcell, kcell, isbeg, jsbeg, ksbeg, &
   &                              isend, jsend, ksend, ibbeg, jbbeg, kbbeg, &
   &                              ibend, jbend, kbend, icbeg, jcbeg, icend, &
   &                              jcend, secondhalo, nn, level, sps, sps2)
   ad_from = jcbeg
   ! Loop over the generic subface to set the state in the
   ! halo cells.
   DO j=ad_from,jcend
   ad_from0 = icbeg
   DO i=ad_from0,icend
   CALL PUSHINTEGER4ARRAY(ii, inttype/4)
   ii = i - ioffset
   CALL PUSHINTEGER4ARRAY(jj, inttype/4)
   jj = j - joffset
   !BCData(nn)%rface(i,j)
   rface = rfaceadj(nnbcs, ii, jj, sps2)
   CALL PUSHREAL8ARRAY(nnx, realtype/8)
   ! Store the three components of the unit normal a
   ! bit easier.
   nnx = normadj(nnbcs, ii, jj, 1, sps2)
   CALL PUSHREAL8ARRAY(nny, realtype/8)
   nny = normadj(nnbcs, ii, jj, 2, sps2)
   CALL PUSHREAL8ARRAY(nnz, realtype/8)
   nnz = normadj(nnbcs, ii, jj, 3, sps2)
   ! Compute the normal velocity of the free stream and
   ! substract the normal velocity of the mesh.
   qn0 = u0*nnx + v0*nny + w0*nnz
   vn0 = qn0 - rface
   ! Compute the three velocity components, the normal
   ! velocity and the speed of sound of the current state
   ! in the internal cell.
   re = one/wadj2(ii, jj, irho)
   ue = wadj2(ii, jj, ivx)
   ve = wadj2(ii, jj, ivy)
   we = wadj2(ii, jj, ivz)
   qne = ue*nnx + ve*nny + we*nnz
   ce = SQRT(gammainf*padj2(ii, jj)*re)
   ! Compute the new values of the riemann invariants in
   ! the halo cell. Either the value in the internal cell
   ! is taken (positive sign of the corresponding
   ! eigenvalue) or the free stream value is taken
   ! (otherwise).
   IF (vn0 .GT. -c0) THEN
   ! Outflow or subsonic inflow.
   ac1 = qne + two*ovgm1*ce
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   ! Supersonic inflow.
   ac1 = qn0 + two*ovgm1*c0
   END IF
   IF (vn0 .GT. c0) THEN
   ! Supersonic outflow.
   ac2 = qne - two*ovgm1*ce
   CALL PUSHINTEGER4(0)
   ELSE
   ! Inflow or subsonic outflow.
   ac2 = qn0 - two*ovgm1*c0
   CALL PUSHINTEGER4(1)
   END IF
   qnf = half*(ac1+ac2)
   CALL PUSHREAL8ARRAY(cf, realtype/8)
   cf = fourth*(ac1-ac2)*gm1
   IF (vn0 .GT. zero) THEN
   CALL PUSHREAL8ARRAY(uf, realtype/8)
   ! Outflow.
   uf = ue + (qnf-qne)*nnx
   CALL PUSHREAL8ARRAY(vf, realtype/8)
   vf = ve + (qnf-qne)*nny
   CALL PUSHREAL8ARRAY(wf, realtype/8)
   wf = we + (qnf-qne)*nnz
   CALL PUSHREAL8ARRAY(sf, realtype/8)
   sf = wadj2(ii, jj, irho)**gammainf/padj2(ii, jj)
   DO l=nt1mg,nt2mg
   CALL PUSHREAL8ARRAY(wadj1(ii, jj, l), realtype/8)
   wadj1(ii, jj, l) = wadj2(ii, jj, l)
   END DO
   CALL PUSHINTEGER4(0)
   ELSE
   CALL PUSHREAL8ARRAY(uf, realtype/8)
   ! Inflow
   uf = u0 + (qnf-qn0)*nnx
   CALL PUSHREAL8ARRAY(vf, realtype/8)
   vf = v0 + (qnf-qn0)*nny
   CALL PUSHREAL8ARRAY(wf, realtype/8)
   wf = w0 + (qnf-qn0)*nnz
   CALL PUSHREAL8ARRAY(sf, realtype/8)
   sf = s0
   DO l=nt1mg,nt2mg
   CALL PUSHREAL8ARRAY(wadj1(ii, jj, l), realtype/8)
   wadj1(ii, jj, l) = winfadj(l)
   END DO
   CALL PUSHINTEGER4(1)
   END IF
   ! Compute the density, velocity and pressure in the
   ! halo cell.
   cc = cf*cf/gammainf
   CALL PUSHREAL8ARRAY(wadj1(ii, jj, irho), realtype/8)
   wadj1(ii, jj, irho) = (sf*cc)**ovgm1
   CALL PUSHREAL8ARRAY(wadj1(ii, jj, ivx), realtype/8)
   wadj1(ii, jj, ivx) = uf
   CALL PUSHREAL8ARRAY(wadj1(ii, jj, ivy), realtype/8)
   wadj1(ii, jj, ivy) = vf
   CALL PUSHREAL8ARRAY(wadj1(ii, jj, ivz), realtype/8)
   wadj1(ii, jj, ivz) = wf
   padj1(ii, jj) = wadj1(ii, jj, irho)*cc
   ! Compute the total energy.
   tmp = ovgm1*padj1(ii, jj) + half*wadj1(ii, jj, irho)*(uf**2+&
   &              vf**2+wf**2)
   CALL PUSHREAL8ARRAY(wadj1(ii, jj, irhoe), realtype/8)
   wadj1(ii, jj, irhoe) = tmp
   IF (kpresent) THEN
   tmp0 = wadj1(ii, jj, irhoe) - factk*wadj1(ii, jj, irho)*&
   &                wadj1(ii, jj, itu1)
   CALL PUSHREAL8ARRAY(wadj1(ii, jj, irhoe), realtype/8)
   wadj1(ii, jj, irhoe) = tmp0
   CALL PUSHINTEGER4(2)
   ELSE
   CALL PUSHINTEGER4(1)
   END IF
   END DO
   CALL PUSHINTEGER4ARRAY(i - 1, inttype/4)
   CALL PUSHINTEGER4(ad_from0)
   END DO
   CALL PUSHINTEGER4ARRAY(j - 1, inttype/4)
   CALL PUSHINTEGER4(ad_from)
   !
   !        Input the viscous effects - rlv1(), and rev1()
   !
   ! Extrapolate the state vectors in case a second halo
   ! is needed.
   IF (secondhalo) THEN
   CALL PUSHREAL8ARRAY(padj0, realtype*5**2/8)
   CALL PUSHREAL8ARRAY(wadj0, realtype*5**2*nw/8)
   CALL EXTRAPOLATE2NDHALONKPC(nnbcs, icbeg, icend, jcbeg, &
   &                                   jcend, ioffset, joffset, wadj0, wadj1&
   &                                   , wadj2, padj0, padj1, padj2)
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   CALL REPLACEBCSTATESNKPC(nnbcs, wadj0, wadj1, wadj2, wadj3, &
   &                              padj0, padj1, padj2, padj3, rlvadj1, &
   &                              rlvadj2, revadj1, revadj2, icell, jcell, &
   &                              kcell, wadj, padj, rlvadj, revadj, &
   &                              secondhalo, nn, level, sps, sps2)
   CALL PUSHINTEGER4(3)
   ELSE
   CALL PUSHINTEGER4(2)
   END IF
   ELSE
   CALL PUSHINTEGER4(1)
   END IF
   END DO bocos
   padj0b = 0.0
   padj1b = 0.0
   padj2b = 0.0
   wadj0b = 0.0
   wadj1b = 0.0
   wadj2b = 0.0
   DO nnbcs=nbocos,1,-1
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 3) THEN
   CALL REPLACEBCSTATESNKPC_B(nnbcs, wadj0, wadj0b, wadj1, wadj1b, &
   &                           wadj2, wadj3, padj0, padj0b, padj1, padj1b, &
   &                           padj2, padj3, rlvadj1, rlvadj2, revadj1, &
   &                           revadj2, icell, jcell, kcell, wadj, wadjb, &
   &                           padj, padjb, rlvadj, revadj, secondhalo, nn, &
   &                           level, sps, sps2)
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 1) THEN
   CALL POPREAL8ARRAY(wadj0, realtype*5**2*nw/8)
   CALL POPREAL8ARRAY(padj0, realtype*5**2/8)
   CALL EXTRAPOLATE2NDHALONKPC_B(nnbcs, icbeg, icend, jcbeg, jcend&
   &                                , ioffset, joffset, wadj0, wadj0b, wadj1&
   &                                , wadj1b, wadj2, wadj2b, padj0, padj0b, &
   &                                padj1, padj1b, padj2, padj2b)
   END IF
   CALL POPINTEGER4(ad_from)
   CALL POPINTEGER4(ad_to)
   DO j=ad_to,ad_from,-1
   CALL POPINTEGER4(ad_from0)
   CALL POPINTEGER4(ad_to0)
   DO i=ad_to0,ad_from0,-1
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 2) THEN
   CALL POPREAL8ARRAY(wadj1(ii, jj, irhoe), realtype/8)
   tmp0b = wadj1b(ii, jj, irhoe)
   wadj1b(ii, jj, irhoe) = tmp0b
   wadj1b(ii, jj, irho) = wadj1b(ii, jj, irho) - factk*wadj1(ii&
   &              , jj, itu1)*tmp0b
   wadj1b(ii, jj, itu1) = wadj1b(ii, jj, itu1) - factk*wadj1(ii&
   &              , jj, irho)*tmp0b
   END IF
   CALL POPREAL8ARRAY(wadj1(ii, jj, irhoe), realtype/8)
   tmpb = wadj1b(ii, jj, irhoe)
   wadj1b(ii, jj, irhoe) = 0.0
   tempb2 = half*wadj1(ii, jj, irho)*tmpb
   padj1b(ii, jj) = padj1b(ii, jj) + ovgm1*tmpb
   cc = cf*cf/gammainf
   wadj1b(ii, jj, irho) = wadj1b(ii, jj, irho) + cc*padj1b(ii, jj&
   &            ) + half*(uf**2+vf**2+wf**2)*tmpb
   wfb = wadj1b(ii, jj, ivz) + 2*wf*tempb2
   wadj1b(ii, jj, ivz) = 0.0
   vfb = wadj1b(ii, jj, ivy) + 2*vf*tempb2
   wadj1b(ii, jj, ivy) = 0.0
   ufb = wadj1b(ii, jj, ivx) + 2*uf*tempb2
   wadj1b(ii, jj, ivx) = 0.0
   IF (sf*cc .LE. 0.0 .AND. (ovgm1 .EQ. 0.0 .OR. ovgm1 .NE. INT(&
   &              ovgm1))) THEN
   tempb3 = 0.0
   ELSE
   tempb3 = ovgm1*(sf*cc)**(ovgm1-1)*wadj1b(ii, jj, irho)
   END IF
   ccb = sf*tempb3 + wadj1(ii, jj, irho)*padj1b(ii, jj)
   padj1b(ii, jj) = 0.0
   CALL POPREAL8ARRAY(wadj1(ii, jj, ivz), realtype/8)
   CALL POPREAL8ARRAY(wadj1(ii, jj, ivy), realtype/8)
   CALL POPREAL8ARRAY(wadj1(ii, jj, ivx), realtype/8)
   CALL POPREAL8ARRAY(wadj1(ii, jj, irho), realtype/8)
   sfb = cc*tempb3
   wadj1b(ii, jj, irho) = 0.0
   cfb = 2*cf*ccb/gammainf
   CALL POPINTEGER4(branch)
   IF (branch .LT. 1) THEN
   DO l=nt2mg,nt1mg,-1
   CALL POPREAL8ARRAY(wadj1(ii, jj, l), realtype/8)
   wadj2b(ii, jj, l) = wadj2b(ii, jj, l) + wadj1b(ii, jj, l)
   wadj1b(ii, jj, l) = 0.0
   END DO
   CALL POPREAL8ARRAY(sf, realtype/8)
   tempb1 = sfb/padj2(ii, jj)
   IF (.NOT.(wadj2(ii, jj, irho) .LE. 0.0 .AND. (gammainf .EQ. &
   &                0.0 .OR. gammainf .NE. INT(gammainf)))) wadj2b(ii, jj, &
   &              irho) = wadj2b(ii, jj, irho) + gammainf*wadj2(ii, jj, irho&
   &                )**(gammainf-1)*tempb1
   padj2b(ii, jj) = padj2b(ii, jj) - wadj2(ii, jj, irho)**&
   &              gammainf*tempb1/padj2(ii, jj)
   CALL POPREAL8ARRAY(wf, realtype/8)
   web = wfb
   qnfb = nny*vfb + nnx*ufb + nnz*wfb
   qneb = -(nny*vfb) - nnx*ufb - nnz*wfb
   CALL POPREAL8ARRAY(vf, realtype/8)
   veb = vfb
   CALL POPREAL8ARRAY(uf, realtype/8)
   ueb = ufb
   ELSE
   DO l=nt2mg,nt1mg,-1
   CALL POPREAL8ARRAY(wadj1(ii, jj, l), realtype/8)
   wadj1b(ii, jj, l) = 0.0
   END DO
   CALL POPREAL8ARRAY(sf, realtype/8)
   CALL POPREAL8ARRAY(wf, realtype/8)
   qnfb = nny*vfb + nnx*ufb + nnz*wfb
   CALL POPREAL8ARRAY(vf, realtype/8)
   CALL POPREAL8ARRAY(uf, realtype/8)
   qneb = 0.0
   ueb = 0.0
   veb = 0.0
   web = 0.0
   END IF
   CALL POPREAL8ARRAY(cf, realtype/8)
   tempb0 = fourth*gm1*cfb
   ac1b = half*qnfb + tempb0
   ac2b = half*qnfb - tempb0
   CALL POPINTEGER4(branch)
   IF (branch .LT. 1) THEN
   qneb = qneb + ac2b
   ceb = -(two*ovgm1*ac2b)
   ELSE
   ceb = 0.0
   END IF
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 1) THEN
   qneb = qneb + ac1b
   ceb = ceb + two*ovgm1*ac1b
   END IF
   re = one/wadj2(ii, jj, irho)
   IF (gammainf*(padj2(ii, jj)*re) .EQ. 0.0) THEN
   tempb = 0.0
   ELSE
   tempb = gammainf*ceb/(2.0*SQRT(gammainf*(padj2(ii, jj)*re)))
   END IF
   padj2b(ii, jj) = padj2b(ii, jj) + re*tempb
   reb = padj2(ii, jj)*tempb
   ueb = ueb + nnx*qneb
   veb = veb + nny*qneb
   web = web + nnz*qneb
   wadj2b(ii, jj, ivz) = wadj2b(ii, jj, ivz) + web
   wadj2b(ii, jj, ivy) = wadj2b(ii, jj, ivy) + veb
   wadj2b(ii, jj, ivx) = wadj2b(ii, jj, ivx) + ueb
   wadj2b(ii, jj, irho) = wadj2b(ii, jj, irho) - one*reb/wadj2(ii&
   &            , jj, irho)**2
   CALL POPREAL8ARRAY(nnz, realtype/8)
   CALL POPREAL8ARRAY(nny, realtype/8)
   CALL POPREAL8ARRAY(nnx, realtype/8)
   CALL POPINTEGER4ARRAY(jj, inttype/4)
   CALL POPINTEGER4ARRAY(ii, inttype/4)
   END DO
   END DO
   CALL POPREAL8ARRAY(wadj1, realtype*5**2*nw/8)
   CALL POPREAL8ARRAY(wadj2, realtype*5**2*nw/8)
   CALL POPREAL8ARRAY(padj1, realtype*5**2/8)
   CALL POPREAL8ARRAY(padj2, realtype*5**2/8)
   CALL POPINTEGER4ARRAY(ioffset, inttype/4)
   CALL POPINTEGER4ARRAY(joffset, inttype/4)
   CALL POPINTEGER4ARRAY(icbeg, inttype/4)
   CALL POPINTEGER4ARRAY(jcbeg, inttype/4)
   CALL POPINTEGER4ARRAY(icend, inttype/4)
   CALL POPINTEGER4ARRAY(jcend, inttype/4)
   CALL POPBOOLEAN(secondhalo)
   wadj3b = 0.0
   padj3b = 0.0
   CALL EXTRACTBCSTATESNKPC_B(nnbcs, wadj, wadjb, padj, padjb, wadj0&
   &                           , wadj0b, wadj1, wadj1b, wadj2, wadj2b, wadj3&
   &                           , wadj3b, padj0, padj0b, padj1, padj1b, padj2&
   &                           , padj2b, padj3, padj3b, rlvadj, revadj, &
   &                           rlvadj1, rlvadj2, revadj1, revadj2, ioffset, &
   &                           joffset, koffset, icell, jcell, kcell, isbeg&
   &                           , jsbeg, ksbeg, isend, jsend, ksend, ibbeg, &
   &                           jbbeg, kbbeg, ibend, jbend, kbend, icbeg, &
   &                           jcbeg, icend, jcend, secondhalo, nn, level, &
   &                           sps, sps2)
   END IF
   CALL POPINTEGER4ARRAY(isbeg, inttype/4)
   CALL POPINTEGER4ARRAY(jsbeg, inttype/4)
   CALL POPINTEGER4ARRAY(ksbeg, inttype/4)
   CALL POPINTEGER4ARRAY(isend, inttype/4)
   CALL POPINTEGER4ARRAY(jsend, inttype/4)
   CALL POPINTEGER4ARRAY(ksend, inttype/4)
   CALL POPINTEGER4ARRAY(ibbeg, inttype/4)
   CALL POPINTEGER4ARRAY(jbbeg, inttype/4)
   CALL POPINTEGER4ARRAY(kbbeg, inttype/4)
   CALL POPINTEGER4ARRAY(ibend, inttype/4)
   CALL POPINTEGER4ARRAY(jbend, inttype/4)
   CALL POPINTEGER4ARRAY(kbend, inttype/4)
   END DO
   END SUBROUTINE BCFARFIELDNKPC_B