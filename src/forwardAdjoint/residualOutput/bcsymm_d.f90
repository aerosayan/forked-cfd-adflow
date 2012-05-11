   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.6 (r4159) - 21 Sep 2011 10:11
   !
   !  Differentiation of bcsymm in forward (tangent) mode:
   !   variations   of useful results: *p *w *rlv
   !   with respect to varying inputs: *p *w *rlv *(*bcdata.norm)
   !   Plus diff mem management of: rev:in p:in gamma:in w:in rlv:in
   !                bcdata:in *bcdata.norm:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcSymm.f90                                      *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 03-07-2003                                      *
   !      * Last modified: 06-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCSYMM_D(secondhalo)
   USE FLOWVARREFSTATE
   USE BLOCKPOINTERS_D
   USE BCTYPES
   USE CONSTANTS
   USE ITERATION
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcSymm applies the symmetry boundary conditions to a block.    *
   !      * It is assumed that the pointers in blockPointers are already   *
   !      * set to the correct block on the correct grid level.            *
   !      *                                                                *
   !      * In case also the second halo must be set the loop over the     *
   !      * boundary subfaces is executed twice. This is the only correct  *
   !      * way in case the block contains only 1 cell between two         *
   !      * symmetry planes, i.e. a 2D problem.                            *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Subroutine arguments.
   !
   LOGICAL, INTENT(IN) :: secondhalo
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: kk, mm, nn, i, j, l
   REAL(kind=realtype) :: vn, nnx, nny, nnz
   REAL(kind=realtype) :: vnd, nnxd, nnyd, nnzd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1d, ww2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1d, pp2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: gamma1, gamma2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1d, rlv2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: gamma1d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1d
   INTERFACE 
   SUBROUTINE SETBCPOINTERS(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, &
   &        rev1, rev2, offset)
   USE BLOCKPOINTERS_D
   INTEGER(kind=inttype), INTENT(IN) :: nn, offset
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   END SUBROUTINE SETBCPOINTERS
   END INTERFACE
      INTERFACE 
   SUBROUTINE SETBCPOINTERS_D(nn, ww1, ww1d, ww2, ww2d, pp1, pp1d, &
   &        pp2, pp2d, rlv1, rlv1d, rlv2, rlv2d, rev1, rev2, offset)
   USE BLOCKPOINTERS_D
   INTEGER(kind=inttype), INTENT(IN) :: nn, offset
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1d, ww2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1d, pp2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1d, rlv2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   END SUBROUTINE SETBCPOINTERS_D
   END INTERFACE
      !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Set the value of kk; kk == 0 means only single halo, kk == 1
   ! double halo.
   kk = 0
   IF (secondhalo) kk = 1
   ! Loop over the number of times the halo computation must be done.
   nhalo:DO mm=0,kk
   ! Loop over the boundary condition subfaces of this block.
   bocos:DO nn=1,nbocos
   ! Check for symmetry boundary condition.
   IF (bctype(nn) .EQ. symm) THEN
   ! Nullify the pointers, because some compilers require that.
   !nullify(ww1, ww2, pp1, pp2, rlv1, rlv2, rev1, rev2)
   ! Set the pointers to the correct subface.
   CALL SETBCPOINTERS_D(nn, ww1, ww1d, ww2, ww2d, pp1, pp1d, pp2, &
   &                       pp2d, rlv1, rlv1d, rlv2, rlv2d, rev1, rev2, mm)
   ! Set the additional pointers for gamma1 and gamma2.
   SELECT CASE  (bcfaceid(nn)) 
   CASE (imin) 
   gamma1 => gamma(1, 1:, 1:)
   gamma2 => gamma(2, 1:, 1:)
   CASE (imax) 
   gamma1 => gamma(ie, 1:, 1:)
   gamma2 => gamma(il, 1:, 1:)
   CASE (jmin) 
   gamma1 => gamma(1:, 1, 1:)
   gamma2 => gamma(1:, 2, 1:)
   CASE (jmax) 
   gamma1 => gamma(1:, je, 1:)
   gamma2 => gamma(1:, jl, 1:)
   CASE (kmin) 
   gamma1 => gamma(1:, 1:, 1)
   gamma2 => gamma(1:, 1:, 2)
   CASE (kmax) 
   gamma1 => gamma(1:, 1:, ke)
   gamma2 => gamma(1:, 1:, kl)
   END SELECT
   ! Loop over the generic subface to set the state in the
   ! halo cells.
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   ! Store the three components of the unit normal a
   ! bit easier.
   nnxd = bcdatad(nn)%norm(i, j, 1)
   nnx = bcdata(nn)%norm(i, j, 1)
   nnyd = bcdatad(nn)%norm(i, j, 2)
   nny = bcdata(nn)%norm(i, j, 2)
   nnzd = bcdatad(nn)%norm(i, j, 3)
   nnz = bcdata(nn)%norm(i, j, 3)
   ! Determine twice the normal velocity component,
   ! which must be substracted from the donor velocity
   ! to obtain the halo velocity.
   vnd = two*(ww2d(i, j, ivx)*nnx+ww2(i, j, ivx)*nnxd+ww2d(i, j&
   &              , ivy)*nny+ww2(i, j, ivy)*nnyd+ww2d(i, j, ivz)*nnz+ww2(i, &
   &              j, ivz)*nnzd)
   vn = two*(ww2(i, j, ivx)*nnx+ww2(i, j, ivy)*nny+ww2(i, j, &
   &              ivz)*nnz)
   ! Determine the flow variables in the halo cell.
   ww1d(i, j, irho) = ww2d(i, j, irho)
   ww1(i, j, irho) = ww2(i, j, irho)
   ww1d(i, j, ivx) = ww2d(i, j, ivx) - vnd*nnx - vn*nnxd
   ww1(i, j, ivx) = ww2(i, j, ivx) - vn*nnx
   ww1d(i, j, ivy) = ww2d(i, j, ivy) - vnd*nny - vn*nnyd
   ww1(i, j, ivy) = ww2(i, j, ivy) - vn*nny
   ww1d(i, j, ivz) = ww2d(i, j, ivz) - vnd*nnz - vn*nnzd
   ww1(i, j, ivz) = ww2(i, j, ivz) - vn*nnz
   ww1d(i, j, irhoe) = ww2d(i, j, irhoe)
   ww1(i, j, irhoe) = ww2(i, j, irhoe)
   ! Simply copy the turbulent variables.
   DO l=nt1mg,nt2mg
   ww1d(i, j, l) = ww2d(i, j, l)
   ww1(i, j, l) = ww2(i, j, l)
   END DO
   ! Set the pressure and gamma and possibly the
   ! laminar and eddy viscosity in the halo.
   gamma1(i, j) = gamma2(i, j)
   pp1d(i, j) = pp2d(i, j)
   pp1(i, j) = pp2(i, j)
   IF (viscous) THEN
   rlv1d(i, j) = rlv2d(i, j)
   rlv1(i, j) = rlv2(i, j)
   END IF
   IF (eddymodel) THEN
   rev1d(i, j) = 0.0
   rev1(i, j) = rev2(i, j)
   END IF
   END DO
   END DO
   END IF
   END DO bocos
   END DO nhalo
   END SUBROUTINE BCSYMM_D
