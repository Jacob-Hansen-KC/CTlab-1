

program hello
    implicit none
    integer :: n=110,i
    real(8) :: total
    total=1
    do i=1,n
        total=total*i
    end do
    print *, n,'!=',total
end program hello