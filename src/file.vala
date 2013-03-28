using GLib;

namespace NSFile{
	/* following method could be in the Loading class instead, 
	 then private with use of public property */
	/* lists all files of an certain path, which have a certain prefix, suffix */
	public List<string> dir(string path, bool relative_to_home=true, 
	                    string prefix="", string suffix=""){
		List<string> filename_list = new List<string> ();
		string complete_path = path;
		try {
			if (relative_to_home == true){
				string home = Environment.get_home_dir();
				// used as new path eg "/.local/share/theodora-transcode/"
				complete_path = home + path;
			}

			var directory = File.new_for_path (complete_path);
			
			string filename;
			var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

			FileInfo file_info;
			while ((file_info = enumerator.next_file ()) != null) {
				filename = file_info.get_name ();
				if (filename.has_prefix(prefix) == true){
					if (filename.has_suffix(suffix) == true){
						filename_list.append(filename);
					}
				}
			}
		}
		catch (Error e) {
				stderr.printf ("Error: %s\n", e.message);
		}
		return filename_list;
	}
	
	/* change directory and create it, if it does not exist */
	public int cd(string new_path, bool relative_to_home=true){
		string path = new_path;
		if (relative_to_home == true){
			string home = Environment.get_home_dir();

			// new path used usually: "/.local/share/theodora-transcode/"
			path = home + new_path;
		}

		if (Environment.set_current_dir(path)==-1){
				if (DirUtils.create_with_parents(path, 0700) == -1){
					stderr.printf("attempt to create directory failed!\n");
					return -1;
				}
				if (Environment.set_current_dir(path) == -1){
					stderr.printf("attempt to change directory failed!\n");
					return -1;
				}
		}	
		return 0;
	}
	
	// retrieve parameters from file
	public class Loading : Object
	{	
		private Json.Object _file_info;
		public Json.Object file_info{
			get {return _file_info;}
		}
	
		public Loading(string file)
		{
			get_json_object(file);
		}

		/* used in Command.Create and Widgets.Adjustment */
		private List<string> _valuelist;
		public List<string> valuelist{
			get {return _valuelist;}
		}

		private void get_json_object(string file){
			try{
				size_t length;
				var parser = new Json.Parser ();
				//NSFile.cd(Main.PROFILE_PATH, true);
				parser.load_from_file(file);
				_file_info = parser.get_root().get_object ();
			} catch (Error e) {
				stderr.printf ("Error: Something in Loading went wrong...\n");
			} 
		}

		public void create_valuelist(uint8 mode){
			_valuelist = new List<string> ();
			uint8 j=0;
			string[] categories;

			if (mode==0){ /* the order of the categories matters! */
				categories = {"basics", "quality", "crop", "terminal", "color"};
			}
			else if (mode==1){
				categories = {"color", "quality", "terminal", "crop"};
			}
			else categories = {"color", "quality", "terminal"};
			
			foreach (string category in categories) {
				// create a list of the values
				var node = new Json.Node(Json.NodeType.ARRAY);

				node = _file_info.get_member(category);
				var dup_object = node.dup_object ();
				var list = dup_object.get_values();

				uint8 i = 0;
				list.foreach ((node) => {
				 // TODO: add all values as string to a list
					string? val = null;
					val = node.type_name();
					switch(val){
						case "String":
							val = node.get_string();
							break;
						case "Boolean":
							val = node.get_boolean().to_string();
							break;
						case "Floating Point":
							val = node.get_double().to_string();
							break;
						case "Integer":
							val = node.get_int().to_string("%d");
								break;
						default:
							break;
					}
					_valuelist.append(val);
					i++;           
				});
				j++;
			}
		}
	
	}

	// save all parameters to a File
	public class Saving : Object
	{
		public Saving(string filename)
		{	
			size_t length; 
			
			//NSFile.cd(Main.PROFILE_PATH, true);
			string output = NSWidgets.Query.generator.to_data(out length);
			FileUtils.set_contents(filename, output);			
		}
	}
}