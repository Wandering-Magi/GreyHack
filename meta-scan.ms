// ============================================================================ 
// Parameter help check
// ============================================================================ 
if params.len != 1 or params[0] == "-h" or params[0] == "--help" then 
  exit("<b>Usage: "+program_path.split("/")[-1]+" [ip_address]</b>")
end if



// ============================================================================ 
// Load external libraries
//
// Metaxploit 
// ============================================================================ 
metaxploit = include_lib("/lib/metaxploit.so")
if not metaxploit then
  metaxploit = include_lib(current_path + "/metaxploit.so")
end if
if not metaxploit then exit("Error: Can't find metaxploit library in the /lib path or the current folder")

// ============================================================================ 
// BinDB 
// ============================================================================ 
bindb = import_code("/home/Magi/src/libbindb.src")
if not bindb then
  bindb = import_code("/home/Magi/src/libbindb.src")
end if
if not bindb then exit("Error: Can't ind libbindb.src in the current folder")

// ============================================================================ 
// Initialize binaries
// ============================================================================ 
vulnDB = BinDB.connect("vuln", "gNavlWj3Tazz8h", "[lib]", "/home/Magi/.bin")



// ============================================================================
// FUNCTIONS
// ============================================================================
parse_parameters = function(params)
  
end function

get_vuln_target = function(str)
  s = str.indexOf("<b>")
  e = str.indexOf("</b>")

  if s != null and e != null then
    s = s + "<b>".len
    result = str[s:e]
  else
    result = ""
  end if
  return result
end function

// Create a null session with the target address to get information
// on available libraries
make_null_session = function(address)
  //address = params[0]
  net_session = metaxploit.net_use(address)
  if not net_session then exit("Error: Can't connect to net session")
  return net_session.dump_lib
end function

scan_metaxploit = function(net_dump)
  return metaxploit.scan(net_dump)
end function



// ============================================================================ 
// State Machine
// ============================================================================
States = {
    "IDLE": 0,
    "RUNNING": 1,
    "PAUSED": 2,
    "STOPPED": 3
}
StateMachine = {}
// Define variables
StateMahine.currentState = "IDLE" // initial state
StateMachine.states = States
StateMachine.params = params // TODO: add proper param parser into new map

StateMachine.update = function
  self.states[currentState](self)
end function

StateMachine.transition = function(newState)
  if self.hasIndex(newState) then
    self.currentState = newState
    self.update()
  else
    exit("Error: Unknown State ["+newState+"]")
  end if
end function

states = {
  "idle": function(self)
    print("Entered idle state")
    self.transition("start session")
  end function,
  "start session": function(self)
    print("==== Starting Session with target ====")
    self.net = make_nul_session(self.params[0])
    print(self.net.lib_name+" v"+self.net.version)
  end function,
  "stopped": function
    print("Entered stopped state")
  end function
}
//sm = new StateMachine(states, params)
//sm.update  // runs idle logic
//
//// Simulate event
//if someCondition then
//    sm.transition("running")
//end if
//sm.update  // now runs running logic
//
//print("===== Beginning Scan ======")
//metaScan = metaxploit.scan(metaLib)
//
//print("Found "+metaScan.len+" exploits")
//i = 0
//for vuln in metaScan
//  i = i+1
//  memory_scan = metaxploit.scan_address(metaLib, vuln)
//  mem_arr = memory_scan.split("\n")
//  print(i+": "+vuln)
//  for each in mem_arr
//    v_target = get_vuln_target(each)
//    if v_target.len > 0 then 
//      result = metaLib.overflow(vuln, v_target)
//      print(v_target+": "+typeof(result))
//    end if
//  end for
//end for
//print(metaLib.lib_name+" v"+metaLib.version)
//exit("===== Scan complete =====")


// ============================================================================
// Main loop
// ============================================================================
main = new StateMachine(states, params)
main.update
