program Primes_Parra
  use openacc
  implicit none
  integer :: k, n, is_prime, kk=221184
  integer, allocatable :: prime_flags(:)
  real :: t_start, t_end

  allocate(prime_flags(kk))
  prime_flags = 0

  call cpu_time(t_start)



  !$acc data copy(prime_flags)
  !$acc parallel loop vector_length(128) gang num_gangs(1728)
  do k = 2, kk-1
    is_prime = 1
    do n = 2, k - 1
      if (mod(k, n) == 0) then
        is_prime = 0
      end if
    end do
    if (is_prime == 1) then
      prime_flags(k) = 1
    end if
  end do
  !$acc end parallel loop
  !$acc end data



  call cpu_time(t_end)

  print *, 'Primes less than:',kk
  do k = 2, kk-1
    if (prime_flags(k) == 1) then
      print *, k
    end if
  end do

  print *, 'Execution time: ', t_end - t_start, ' seconds'

  deallocate(prime_flags)
end program Primes_Parra