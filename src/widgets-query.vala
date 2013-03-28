using GLib;

namespace NSWidgets{
	// query all used parameters
	public class Query : Main
	{	
		public Query()
		{
		}

		// Note: without "static" Segmentation fault
		private static Json.Generator _generator;
		public static Json.Generator generator{
			get {return _generator;}
		}

		/* method to update the property, depending on the mode
		 * mode 0 = Query, mode 1 programm closing, 2 profile loading/saving */
		[CCode (cname="update_rootobject", instance_pos=-1)]
		private void update_rootobject(uint8 mode)
		{
			Variant dictionary = widgets_to_check(mode);
			Variant? val = null;
			string? key = null;
			
			//var node = new Json.Node(Json.NodeType.ARRAY);
			var root = new Json.Node(Json.NodeType.OBJECT);
			var robject = new Json.Object();
			var object = new Json.Object();
			_generator = new Json.Generator();
			_generator.pretty = true;
			root.set_object(robject);
			_generator.set_root(root);

			VariantIter iter = dictionary.iterator();

			while(iter.next("{sv}", &key, &val)){
				object = query_category(key, val);
				robject.set_object_member (key, object);
			} 
		}

		//public Window
		[CCode (cname="main_on_destroy", instance_pos = -1)]
		public void main_on_destroy (Gtk.Widget window) 
		{
			update_rootobject(1); 
			//NSFile.cd(PROFILE_PATH, true);
			NSFile.Saving save_file = new NSFile.Saving(PROFILE_MODE1 + ".json");
			Gtk.main_quit();
		}

		[CCode (cname="on_btn_conversion_clicked", instance_pos=-1)]
		public void on_btn_conversion_clicked (Gtk.Button sender) 
		{ 	/* create a Json.Generator, which knowns which widgettypes to check 
			 * for which category */
			if (error_infbar != null) error_infbar.destroy();
		/* first make sure both source and output is specified */
		/* get sourcename */
			var source_fbtn = builder.get_object("fbtn_basics0") as Gtk.FileChooser;
			string input = source_fbtn.get_filename();
		/* get targetfilename */
			var target_e = builder.get_object("e_basics0") as Gtk.Entry;
			string target = target_e.get_text();
			if ( (input == "") || (target == "") ){
					built_infbar_layout(Gtk.MessageType.WARNING, "Not started yet! " +
						                "Please specify the input and output file first!");
					return;
				}
			
		/* create the first part of the command (command without source and target) */
			update_rootobject(0); 
			NSFile.cd(PROFILE_PATH, true);
			NSFile.Saving save_file = new NSFile.Saving("last_" + LAST_PROFILE + ".json");

			NSCommand.Creation command = new NSCommand.Creation();
			string c = command.conversion_command;

		/* check if subtitle is to set */
			var subtitle_file_rbtn = builder.get_object("rbtn_basics1") as Gtk.ToggleButton;
			if (subtitle_file_rbtn.get_active() == true){
				var subtitle_fbtn = builder.get_object("fbtn_basics1") as Gtk.FileChooser;
				c = c + " --subtitles " + subtitle_fbtn.get_filename();
			}
		/* make the command complete*/
			c = c + " '" + input + "' -o '" + target + "'\"";
			
			var sbar = builder.get_object("sbar") as Gtk.Statusbar;
			sbar.push(0, "executed: " + c);
			sbar.set_tooltip_text(c);
	
		/* set working path to the home folder */
			string home = Environment.get_home_dir();
			Environment.set_current_dir(home);
			
			NSCommand.Execution process = new NSCommand.Execution();
			process.async_command(c);			
			NSFile.cd(PROFILE_PATH, true);

			built_infbar_layout(Gtk.MessageType.INFO, "During conversion, " +
			                    "better not close this GUI and neither the terminal! " +
			                    "\nOtherwise the conversion will be stopped!", "Hide");
		}

		/* method to update the two invisible labels in the basics infobar */
		[CCode (cname="on_btn_conversion_clicked_update_timelabel", instance_pos=-1)]
		public void on_btn_conversion_clicked_update_timelabel (Gtk.Button sender, 
		                                                        Gtk.Grid grid){
			var start_grid = grid.get_child_at(0, 1) as Gtk.Grid;
			var minutes_widget = start_grid.get_child_at(0, 0) as Gtk.Entry;
			var seconds_widget = start_grid.get_child_at(1, 0) as Gtk.SpinButton;
			var lbl = start_grid.get_child_at(2, 1) as Gtk.Label;
			
			double seconds = int.parse(minutes_widget.get_text())*60 +
						  int.parse(seconds_widget.get_text());
			lbl.set_text(seconds.to_string());

			var end_grid = grid.get_child_at(1, 1) as Gtk.Grid;
			lbl = end_grid.get_child_at(2, 1) as Gtk.Label;
			minutes_widget = end_grid.get_child_at(0, 0) as Gtk.Entry;
			seconds_widget = end_grid.get_child_at(1, 0) as Gtk.SpinButton;
			seconds = int.parse(minutes_widget.get_text())*60 +
						  int.parse(seconds_widget.get_text());
			lbl.set_text(seconds.to_string());				
		}

		[CCode (cname="on_btn_save_profile_clicked", instance_pos=-1)]
		public void on_btn_save_profile_clicked (Gtk.Button sender) {
			var profile_e = builder.get_object("e_profile") as Gtk.Entry;
			update_rootobject(2);

			//NSFile.cd(PROFILE_PATH, true);	
			string profilename = profile_e.get_text();
			NSFile.Saving save = new NSFile.Saving("profile_" + profilename + ".json");

			var sbar = builder.get_object("sbar") as Gtk.Statusbar;
			sbar.push(0, "saved in profile '" + profilename + "': color-, quality-" +
				" and additional parameter settings");
			sbar.set_tooltip_text("");
		}

		public static Variant widgets_to_check(uint8 mode)
		{
			/* Modes: {0: query for transcoding, 1: program start/close,
					2: loading/saving } */

			VariantBuilder vbuilder = new VariantBuilder (new VariantType ("a{sv}") );

			// all modes share same "color" and "quality" dict entry
			vbuilder.add ("{sv}", "color", new Variant.tuple({"scale"}));
			vbuilder.add ("{sv}", "quality", new Variant.tuple({"scale", "e",
					"cbtn"}));

			if (mode==0){
				// in "quality" sbtn named scale
				vbuilder.add ("{sv}", "basics", new Variant.tuple({
								"e", "rbtn", "lbl"}));
			}
			if (mode==0){
				vbuilder.add ("{sv}", "crop", new Variant.tuple({"sbtn"}));
				
			}
			/* mode 0 and 1 */
			if (mode!=2){ // Note: ce is a entry, which mode2 should not query
				vbuilder.add ("{sv}", "terminal", new Variant.tuple({"e", "ce"}));
			} 

			if (mode==2){
				vbuilder.add ("{sv}", "terminal", new Variant.tuple({"e"}));
			}

			if (mode==1){
				vbuilder.add ("{sv}", "crop", new Variant.tuple({"e"}));
			}

			Variant dictionary = vbuilder.end ();
			return dictionary;
		}
	
		protected Json.Object query_category(string category, Variant widgettypes){
			uint8 i=0;

		/* FIXME this method raises Gtk-Critical warnings 'GTK_IS_BULDER' failed */

			var object = new Json.Object();
			while (i<widgettypes.n_children ()){
				string type = widgettypes.get_child_value(i).get_string();

				switch(type)
				{
					/* in all cases iterate through all widgets of its case
					 * and add it to object; */
					case "scale": // same case as "sbtn"
					case "sbtn":
						double val;
						uint8 j = 0;

						var adjust = builder.get_object(
							    "adjust_" + category + "0") as Gtk.Adjustment; 
						while(adjust != null) {
							string? description = null;
							var iter = get_description(category, type, j);
							iter.next("s", &description);
							val = adjust.get_value();
							object.set_double_member(description, val); 
							j++;
							adjust = builder.get_object(
							    "adjust_" + category + j.to_string ("%d")) as Gtk.Adjustment;
						} 
						break;
					/*case "cbox":
						string val;
						uint8 j = 0;

						var cbox = builder.get_object(
							    type + "_" + category + "0") as Gtk.ComboBoxText; 
						while(cbox != null) {
							string? description = null;
							var iter = get_description(category, type, j);
							iter.next("s", &description);
							val = cbox.get_active_text();
							object.set_string_member(description, val); 
							j++;
							cbox = builder.get_object(
							    type + "_" + category + j.to_string ("%d")) as Gtk.ComboBoxText; 
						} 						
						break;*/
					case "cbtn": // same case as "rbtn"
					case "rbtn":
						bool val;
						uint8 j = 0;
						var cbtn = builder.get_object(
							    type + "_" + category + "0") as Gtk.ToggleButton; 
						while(cbtn != null) {
							string? description = null;
							var iter = get_description(category, type, j);
							iter.next("s", &description);
							val = cbtn.get_active();
							object.set_boolean_member(description, val); 
							j++;
							cbtn = builder.get_object(
							   type + "_" + category + j.to_string ("%d")) as Gtk.ToggleButton;
						}						
						break;
					/*case "fbtn":
						string val;
						uint8 j = 0;
						var fbtn = builder.get_object(
							    type + "_" + category + "0") as Gtk.FileChooser; 
						while(fbtn != null) {
							string? description = null;
							var iter = get_description(category, type, j);
							iter.next("s", &description);
							val = fbtn.get_uri();
							object.set_string_member(description, val); 
							j++;
							fbtn = builder.get_object(
							    type + "_" + category + j.to_string ("%d")) as Gtk.FileChooser;
						}
						break;*/
					case "e":
					case "ce":
						string val;
						uint8 j = 0;
						var e = builder.get_object(
							    type + "_" + category + "0") as Gtk.Entry; 
						while(e != null) {
							string? description = null;
							var iter = get_description(category, type, j);
							iter.next("s", &description);
							val = e.get_text();
							object.set_string_member(description, val); 
							j++;
							e = builder.get_object(
							     type + "_" + category + j.to_string ("%d")) as Gtk.Entry;
						}
						break;
					case "lbl": // almost same as case "e"! Perhaps possible to merge?!
						string val;
						uint8 j = 0;
						Gtk.Label? lbl=null;
							
						lbl = builder.get_object (
						         type + "_" + category + "0") as Gtk.Label;
						while(lbl != null) {
							string? description = null;
							var iter = get_description(category, type, j);
							iter.next("s", &description);
							val = lbl.get_text();
							object.set_string_member(description, val);
							j++;
							lbl=null;
							lbl = builder.get_object(
								type + "_" + category + j.to_string ("%d")) as Gtk.Label;
						}
						break;
						       
					default:
						stdout.printf("unknown type, %s\n", type);
						break;		
				}
				i++;
			}
			return object;
		}

		/* purpose: descriptive name in saved profiles, so that the Json files
		 * can be modified via texteditors */ 
		public static VariantIter get_description(string category, string type, uint8 number){
			/* not all widgets need a descriptive name, all from basic category ommited */
			string defaultstring = type + "_" + category + number.to_string("%d");
			Variant var1 = new Variant("(s)", defaultstring); // the default
			
			switch (category)
			{
				case "quality":
					if (type == "scale"){
						if (number == 0) var1 = new Variant("(s)", "Video Quality");
						if (number == 1) var1 = new Variant("(s)", "Audio Quality");
						if (number == 2) var1 = new Variant("(s)", "Video Bitrate");
						if (number == 3) var1 = new Variant("(s)", "Audio Bitrate");
						if (number == 4) var1 = new Variant("(s)", "Height"); 
						if (number == 5) var1 = new Variant("(s)", "Framerate"); 
					}
					if (type == "cbtn"){
						if (number == 0) var1 = new Variant("(s)", 
						                                    "use specific Video Bitrate");
						if (number == 1) var1 = new Variant("(s)", 
						                                    "use specific Audio Bitrate");
						if (number == 2) var1 = new Variant("(s)",
						                                    "same framerate as source file");
						if (number == 3) var1 = new Variant("(s)", 
						                                    "enable optimization");
						if (number == 4) var1 = new Variant("(s)", "use soft-target");
						if (number == 5) var1 = new Variant("(s)", 
						                                    "use two-pass rate control");
					}
					if (type == "e"){
						if (number == 0) var1 = new Variant("(s)", "Width");						
					}
					return var1.iterator();
				case "color":
					if (type == "scale"){
						if (number == 0) var1 = new Variant("(s)", "Contrast");
						if (number == 1) var1 = new Variant("(s)", "Brightness");
						if (number == 2) var1 = new Variant("(s)", "Gamma");
						if (number == 3) var1 = new Variant("(s)", "Saturation");
					}
					return var1.iterator();
				case "terminal":
					if (type == "e"){
						if (number == 0) var1 = new Variant("(s)",
												"Additional parameters");
					}
					if (type == "ce"){
						if (number == 0) var1 = new Variant("(s)",
												"Terminal");
					}
					return var1.iterator();
				/*case "profile":
					if (type == "cbox"){
							if (number == 0) var1 = new Variant("(s)",
							                     "Profilname");
					}
					return var1.iterator();*/
				default:				
					return var1.iterator();	
			}
			        
		}		

		[CCode (cname="on_btn_preview_clicked", instance_pos=-1)]
		public void on_btn_preview_clicked (Gtk.Button sender) {
			/* the json file text is not saved or queried (?) as unicode, 
			 * that is one reason why it is queried in there and not saved 
			 * and taken from the JSON file */
			
		/* first update the invisible start and endtime label */ 
			var start_lbl = builder.get_object("lbl_basics0") as Gtk.Label;
			var end_lbl = builder.get_object("lbl_basics1") as Gtk.Label;
			var preview_grid = sender.get_parent() as Gtk.Grid;
			var minutes_e = preview_grid.get_child_at(0, 1) as Gtk.Entry;
			var seconds_sbtn = preview_grid.get_child_at(1, 1) as Gtk.SpinButton;
			var duration_sbtn = preview_grid.get_child_at(2, 1) as Gtk.SpinButton;
			int starttime = int.parse(minutes_e.get_text())*60 +
												seconds_sbtn.get_value_as_int();
			int endtime = starttime + duration_sbtn.get_value_as_int();
			start_lbl.set_text(starttime.to_string("%d"));
			end_lbl.set_text(endtime.to_string("%d"));  

		/* update the values in 'most recent.json' */
			update_rootobject(0);

			//NSFile.cd(PROFILE_PATH, true);
			NSFile.Saving save = new NSFile.Saving("last_" + LAST_PROFILE + ".json");			

			NSCommand.Creation command = new NSCommand.Creation();
			string c = command.conversion_command;

		/* check if subtitle is to set */
			var subtitle_file_rbtn = builder.get_object("rbtn_basics1") as Gtk.ToggleButton;
			if (subtitle_file_rbtn.get_active() == true){
				var subtitle_fbtn = builder.get_object("fbtn_basics1") as Gtk.FileChooser;
				c = c + " --subtitles " + subtitle_fbtn.get_filename();
			}

		/* get sourcename */
			var source_fbtn = builder.get_object("fbtn_basics0") as Gtk.FileChooser;
			string input = source_fbtn.get_filename();

		/* add outputname /tmp/preview.ogv */
			string tmp_dir = Environment.get_tmp_dir();
			c = c + " '" + input + "' -o " + tmp_dir + "/preview.ogv";   

		/* check if cbtn "more speed..." is active */
			var cbtn_more_speed = builder.get_object("cbtn_preview") 
															as Gtk.ToggleButton;
			if (cbtn_more_speed.get_active() == true){
				c = c.replace("--optimize", "");
				c = c.replace("--two-pass", "");
				c = c.replace("ffmpeg2theora --st",	"ffmpeg2theora --speedlevel 2 --st");
			}

		/* cut off the terminal info at the beginning*/
			int index = c.index_of("-e \"ffm", 3) + 4;
			c = c.splice(0, index, "");
			
			stdout.printf("execute command: \n %s\n", c);
			
			var sbar = builder.get_object("sbar") as Gtk.Statusbar;
			
			sbar.push(0, "executed: " + c);
			sbar.set_tooltip_text(c);
			
			NSCommand.Execution process = new NSCommand.Execution();
			
			process.sync_command(c);
			var cboxt_player = builder.get_object("cboxt_crop") as Gtk.ComboBoxText;
			string player = cboxt_player.get_active_text();

			process.async_command(player + " '/tmp/preview.ogv'");
		}
	}
}
