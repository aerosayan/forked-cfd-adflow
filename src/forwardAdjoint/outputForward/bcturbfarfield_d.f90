   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of bcturbfarfield in forward (tangent) mode (with options i4 dr8 r8):
   !   variations   of useful results: *bvtj1 *bvtj2 *bvtk1 *bvtk2
   !                *bvti1 *bvti2
   !   with respect to varying inputs: *bvtj1 *bvtj2 *bvtk1 *bvtk2
   !                *bvti1 *bvti2 winf
   !   Plus diff mem management of: bvtj1:in bvtj2:in bvtk1:in bvtk2:in
   !                bvti1:in bvti2:in bcdata:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcTurbFarfield.f90                              *
   !      * Author:        Georgi Kalitzin, Edwin van der Weide            *
   !      * Starting date: 06-15-2003                                      *
   !      * Last modified: 06-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCTURBFARFIELD_D(nn)
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcTurbFarfield applies the implicit treatment of the           *
   !      * farfield boundary condition to subface nn. As the farfield     *
   !      * boundary condition is independent of the turbulence model,     *
   !      * this routine is valid for all models. It is assumed that the   *
   !      * pointers in blockPointers are already set to the correct       *
   !      * block on the correct grid level.                               *
   !      *                                                                *
   !      ******************************************************************
   !
   USE BLOCKPOINTERS_D
   USE BCTYPES
   USE CONSTANTS
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   !
   !      Subroutine arguments.
   !
   INTEGER(kind=inttype), INTENT(IN) :: nn
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, l
   REAL(kind=realtype) :: nnx, nny, nnz, dot
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Loop over the faces of the subfaces and set the values of
   ! bmt and bvt for an implicit treatment.
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   ! Determine the dot product between the outward pointing
   ! normal and the free stream velocity direction and add the
   ! possible grid velocity.
   dot = bcdata(nn)%norm(i, j, 1)*winf(ivx) + bcdata(nn)%norm(i, j, 2&
   &       )*winf(ivy) + bcdata(nn)%norm(i, j, 3)*winf(ivz) - bcdata(nn)%&
   &       rface(i, j)
   ! Determine whether we are dealing with an inflow or
   ! outflow boundary here.
   IF (dot .GT. zero) THEN
   ! Outflow. Simply extrapolation or zero Neumann BC
   ! of the turbulent variables.
   DO l=nt1,nt2
   SELECT CASE  (bcfaceid(nn)) 
   CASE (imin) 
   bmti1(i, j, l, l) = -one
   CASE (imax) 
   bmti2(i, j, l, l) = -one
   CASE (jmin) 
   bmtj1(i, j, l, l) = -one
   CASE (jmax) 
   bmtj2(i, j, l, l) = -one
   CASE (kmin) 
   bmtk1(i, j, l, l) = -one
   CASE (kmax) 
   bmtk2(i, j, l, l) = -one
   END SELECT
   END DO
   ELSE
   ! Inflow. Turbulent variables are prescribed.
   DO l=nt1,nt2
   SELECT CASE  (bcfaceid(nn)) 
   CASE (imin) 
   bvti1d(i, j, l) = winfd(l)
   bvti1(i, j, l) = winf(l)
   CASE (imax) 
   bvti2d(i, j, l) = winfd(l)
   bvti2(i, j, l) = winf(l)
   CASE (jmin) 
   bvtj1d(i, j, l) = winfd(l)
   bvtj1(i, j, l) = winf(l)
   CASE (jmax) 
   bvtj2d(i, j, l) = winfd(l)
   bvtj2(i, j, l) = winf(l)
   CASE (kmin) 
   bvtk1d(i, j, l) = winfd(l)
   bvtk1(i, j, l) = winf(l)
   CASE (kmax) 
   bvtk2d(i, j, l) = winfd(l)
   bvtk2(i, j, l) = winf(l)
   END SELECT
   END DO
   END IF
   END DO
   END DO
   END SUBROUTINE BCTURBFARFIELD_D
