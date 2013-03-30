using GLib;

namespace NSCommand{
	/* Command class, to built the commands of the current Settings */
	public class Creation : Object{

		// create list of optionaliases
		private const string[] aliases = {"target_NOTUSEDHERE", "--subtitles-encoding", "--subtitles-language", // -1
			 "--nosubtitles", "*", "--starttime", "--endtime", "*-v*", // -6
			"*-a*", "*-V*", "*-A*", "-y", "-F", "-x", "*", "*", "*", "--optimize", // -16
			"--soft-target", "--two-pass", "--croptop", "--cropright", // -20
			"--cropbottom", "--cropleft", "*", "*", "-C", "-B", "-G", "-Z"}; // -28
		/* Note: we do not want to save the fbtn info in the files (unicode issues) */

		private string _conversion_command;
		public string conversion_command{
			get {return _conversion_command;}
		}

		NSFile.Loading loading;
		
		public Creation(){
			//create_valuelist();
			loading = new NSFile.Loading("last_" + Main.LAST_PROFILE + ".json");
			loading.create_valuelist(0);
			set_command();
		}

		private void set_command(){
			uint i=0;
			string c_start="ffmpeg2theora";
			string[] temp= new string[5];
			uint8 count=0;
			
			loading.valuelist.foreach ((val) => {
					switch(i){
						case 0: // target not used
						case 4: // boolean use subtitle file
							break;
						case 7: // video qualifier in temp[0]
						case 8: // audio qualifier in temp[1]
						case 9: // video bitrate in temp[2] 
						case 10: // audio bitrate in temp[3]
						case 12: // Framerate in temp[4]
							temp[count] = val;
							count++;
							break;
						case 14: // video
							if (val=="true") c_start += " -V " + temp[2];
							else c_start += " -v " + temp[0];
							break;
						case 15: // audio
							if (val=="true") c_start += " -A " + temp[3];
							else c_start += " -a " + temp[1];
							break;
						case 16: // framerate
							if (val=="false") c_start += " -F " + temp[4];
							temp = new string[5];
							break;
						case 24: // additional parameters
							c_start += " " + val;
							break;
						case 25: // terminal
							// c_start = val + " -e " + c_start; (better just ignore this case) 
							break;
						default: /* 1, 2, 5, 6, 11, 13, 20, 21, 22, 23, 26-29
								 * and booleans 3, 17, 18, 19 */ // OK
							if (val=="true") c_start += " " + aliases[i];
							else if (val=="false") ; 
							else if (val=="") ;
							else c_start += " " + aliases[i] + " " + val;
							break;
					}
					i++;
			});
			_conversion_command = c_start;	
		}
	
	}
		
	public class Execution : Object{
		private string _info;
		public string info{
			get {return _info;}
		}
		
		public Execution(){
		}
		/* Note: with synced_commands the GUI freezes, during command execution */
		public bool sync_command (string command){			
			try{
				Process.spawn_command_line_sync (command, out _info);
			} catch (SpawnError e){
				stdout.printf("Error: %s\n", e.message);
				return false;
			} 
			return true;
		}

		/* Note: asynced commands don't lock other resources of the programm,
		 * tricky to get info of conversion end */
		public bool async_command (string command){
			try{
				Process.spawn_command_line_async(command);
			} catch (SpawnError e){
				stdout.printf("Error: %s\n", e.message);
				return false;
			}
			return true;
		}
		
	}
}
