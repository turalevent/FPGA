# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BAUD_RATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_DATA_BIT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STOP_BIT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TX_DATA_BIT" -parent ${Page_0}


}

proc update_PARAM_VALUE.BAUD_RATE { PARAM_VALUE.BAUD_RATE } {
	# Procedure called to update BAUD_RATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BAUD_RATE { PARAM_VALUE.BAUD_RATE } {
	# Procedure called to validate BAUD_RATE
	return true
}

proc update_PARAM_VALUE.RX_DATA_BIT { PARAM_VALUE.RX_DATA_BIT } {
	# Procedure called to update RX_DATA_BIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_DATA_BIT { PARAM_VALUE.RX_DATA_BIT } {
	# Procedure called to validate RX_DATA_BIT
	return true
}

proc update_PARAM_VALUE.STOP_BIT { PARAM_VALUE.STOP_BIT } {
	# Procedure called to update STOP_BIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STOP_BIT { PARAM_VALUE.STOP_BIT } {
	# Procedure called to validate STOP_BIT
	return true
}

proc update_PARAM_VALUE.TX_DATA_BIT { PARAM_VALUE.TX_DATA_BIT } {
	# Procedure called to update TX_DATA_BIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_DATA_BIT { PARAM_VALUE.TX_DATA_BIT } {
	# Procedure called to validate TX_DATA_BIT
	return true
}


proc update_MODELPARAM_VALUE.BAUD_RATE { MODELPARAM_VALUE.BAUD_RATE PARAM_VALUE.BAUD_RATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BAUD_RATE}] ${MODELPARAM_VALUE.BAUD_RATE}
}

proc update_MODELPARAM_VALUE.TX_DATA_BIT { MODELPARAM_VALUE.TX_DATA_BIT PARAM_VALUE.TX_DATA_BIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_DATA_BIT}] ${MODELPARAM_VALUE.TX_DATA_BIT}
}

proc update_MODELPARAM_VALUE.RX_DATA_BIT { MODELPARAM_VALUE.RX_DATA_BIT PARAM_VALUE.RX_DATA_BIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_DATA_BIT}] ${MODELPARAM_VALUE.RX_DATA_BIT}
}

proc update_MODELPARAM_VALUE.STOP_BIT { MODELPARAM_VALUE.STOP_BIT PARAM_VALUE.STOP_BIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STOP_BIT}] ${MODELPARAM_VALUE.STOP_BIT}
}

