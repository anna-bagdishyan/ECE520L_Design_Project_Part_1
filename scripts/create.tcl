
set proj_name design_project1_ab
set current_dir [file normalize [file dirname [info script]]]
set repo_dir [file dirname $current_dir]
set proj_dir [file join $repo_dir $proj_name]

if {[file exists $proj_dir]} {
    error "Project directory already exists at $proj_dir. Remove it before re-running this script."
}

create_project $proj_name $proj_dir -part xc7z010clg400-1
set_property target_language Verilog [current_project]

set board_part [lindex [get_board_parts -quiet "digilentinc.com:zybo-z7-10:part0:*"] 0]
if {$board_part ne ""} {
    set_property board_part $board_part [current_project]
}

set src_files [glob -nocomplain [file join $repo_dir src *.v]]
add_files -norecurse $src_files
set_property top spi_master [current_fileset]

set sim_files [glob -nocomplain [file join $repo_dir sim *.v]]
add_files -fileset sim_1 -norecurse $sim_files
set_property top tb_spi_master [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
