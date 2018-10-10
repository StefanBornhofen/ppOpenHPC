module mod_chm
use jcup_interface
use field_common
use component_field, only : component_field_type
private

public :: chm_init
public :: chm_run
public :: chm_fin

integer :: DIV_X
integer :: DIV_Y
integer :: my_comm, my_group, my_rank, my_size

type(component_field_type) :: field


integer :: start_time(6)
integer :: end_time(6)
integer :: itime(6)
integer :: delta_t
integer :: step_counter = 0
integer :: file_id = 46

contains

!======================================================================================================

subroutine chm_init()
  use jcup_interpolation_sample, only : init_interpolation, set_operation_index 
  use field_def, only : init_field_def, set_field_def, cal_mn, get_local_field, cal_grid_index
  use component_field, only : init_field, init_field_data
  use mod_config, only : read_conf, get_start_time, get_end_time, get_step, is_restart
  implicit none
  integer, allocatable :: grid_index(:)
  integer :: lis, lie, ljs, lje
  integer :: i
  integer :: comp_id(2)


  call jcup_set_new_comp(CHM)
  call jcup_initialize(CHM)

  call read_conf("sample.2.cnf")

  call init_interpolation(6,1,3)

  call jcup_get_mpi_parameter(CHM, my_comm, my_group, my_size, my_rank)
  call cal_mn(my_size, DIV_X, DIV_Y)

  call init_field_def(1)
  call set_field_def(component_name = CHM, grid_name = CHM_GRID, &
                     g_nx = GNXC, g_ny = GNYC, g_nz = GNZC, hallo = 2, div_x = DIV_X, div_y = DIV_Y)
  call get_local_field(component_name = CHM, grid_name = CHM_GRID, &
                       local_is = lis, local_ie = lie, local_js = ljs, local_je = lje)

  call init_field(field, CHM_GRID, lis, lie, ljs, lje, 1, GNZC)

  call cal_grid_index(CHM,CHM_GRID, field%grid_index)

  call jcup_def_grid(field%grid_index, CHM, CHM_GRID)
  call jcup_end_grid_def()


  call init_field_data(field, 1, 1, 1)

  call jcup_def_varp(field%varp(1)%varp_ptr, CHM, "chm_1", CHM_GRID)
  call jcup_def_varg(field%varg(1)%varg_ptr, CHM, "atm_1", CHM_GRID, &
                     SEND_MODEL_NAME = ATM, SEND_DATA_NAME = "a_3d_1", &
                     RECV_MODE = "SNP", INTERVAL = 120, TIME_LAG = -1, MAPPING_TAG = 1, EXCHANGE_TAG = 1)

  call jcup_end_var_def()

 

  call jcup_set_mapping_table(ATM, ATM, ATM_GRID_3D, CHM, CHM_GRID, 1)
  call jcup_set_mapping_table(ATM, CHM, CHM_GRID, ATM, ATM_GRID_3D, 1)

  call set_operation_index(CHM,ATM,1)




  start_time = get_start_time()
  end_time = get_end_time()

  itime = start_time
  delta_t = get_step(CHM)

  if (is_restart()) then
    call jcup_read_restart(32, start_time)
    !call mpi_finalize(i)
    !stop
  end if

  if (.not.is_restart()) call jcup_init_time(start_time)

  if (.not.is_restart()) call set_and_put_data(0)

  step_counter = 0

  if (is_restart()) then
    open(unit = file_id, file = trim(CHM)//".mst", form = "formatted", status = "old", err= 200)
    read(file_id, *) step_counter
    close(file_id)
  end if

  return

200 continue

  write(0,*) "no file, "//trim(CHM)//".mst"
  stop

end subroutine chm_init

!======================================================================================================

subroutine set_and_put_data(step)
  use field_def, only : set_send_data_3d
  implicit none
  integer, intent(IN) :: step
  integer :: k

  call set_send_data_3d(CHM,CHM_GRID, field%send_3d(:,:,:), step, 5)
  call jcup_put_data(field%varp(1)%varp_ptr, pack(field%send_3d, MASK = field%mask3d))

end subroutine set_and_put_data

!======================================================================================================

subroutine get_and_write_data()
  use field_def, only : write_data_3d
  implicit none
  integer :: k

  field%buffer1d(:) = 0.d0

  call jcup_get_data(field%varg(1)%varg_ptr, field%buffer1d)
  field%recv_3d(:,:,:) = unpack(field%buffer1d, field%mask3d, field%recv_3d)
  call write_data_3d(CHM,CHM_GRID, "atm_1", field%recv_3d)


end subroutine get_and_write_data

!======================================================================================================

subroutine chm_run(loop_flag)
  use field_def
  use mod_config, only : is_end_step
  implicit none
  logical, intent(INOUT) :: loop_flag
  integer :: i, k

  do !i = 1, 3
    step_counter = step_counter + 1
    call jcup_set_time(CHM, itime, delta_t)

    call get_and_write_data()

    call set_and_put_data(step_counter)

    call jcup_inc_time(CHM, itime)

    if (is_end_step(itime, end_time)) exit

  end do

  loop_flag = .false.

end subroutine chm_run

!======================================================================================================

subroutine chm_fin()
  use jcup_interface
  implicit none
  integer :: i

  call jcup_write_restart(32, end_time)
  call jcup_coupling_end(itime, .true.)

  open(unit = file_id, file = trim(CHM)//".mst", form = "formatted", status = "replace", err = 200)
  write(file_id, *) step_counter
  close(file_id)

  return

200 continue
  write(0,*) "chm data output error"

end subroutine chm_fin

!======================================================================================================


end module mod_chm
