using GLib;


namespace NSWidgets{
/* class for the advice Infoboxes, and the videochooserbutton.
 * Also updates (adjustment) values of widgets
 * and includes all the Button_click or released actions which query something */
	public class Feedback : Main
	{
		protected Gtk.InfoBar advice_infobar;
		
		private static bool update_resolution_on_cropping=false;
		private static bool question_was_asked=false;

		private struct _Crop {
			private int top;
			private int right;
			private int bottom;
			private int left;
		}
		
		private static _Crop crop = {0, 0, 0, 0};


		private static int original_width;
		private static int original_height;
		/* _width, _height stores the resolution original minus cropping */
		private static int _width;
		private static int _height;
		public static int width{
			get {return _width;}
		}
		
		public static int height{
			get {return _height;}
		}

		private static int min=0;
		private static int sec=0;

		public Feedback()
		{		
		}

	/* methods used in the crop category */
		[CCode (cname="on_adjust_crop_value_changed", instance_pos=-1)]
		protected void on_adjust_crop_value_changed (Gtk.Adjustment adjust, 
		                                             Gtk.InfoBar infbar_question){
			if (question_was_asked == false){
				infbar_question.show();
			}
		}
 
		[CCode (cname="on_btn_yes_clicked", instance_pos=-1)]
		protected void on_btn_yes_clicked (Gtk.Button button, 
		                                                 Gtk.Grid grid_crop){			
			uint i=0;
			List<Gtk.SpinButton> sbtn_list = new List <Gtk.SpinButton> ();
			int[] temp_array = {0, 0, 0, 0};
			
			update_resolution_on_cropping=true;
			question_was_asked=true;		

			/* update the cropping struct, to update later the values in the height sbtn */
			sbtn_list.append(grid_crop.get_child_at(3, 0) as Gtk.SpinButton) ; // top
			sbtn_list.append(grid_crop.get_child_at(5, 1) as Gtk.SpinButton); // right
			sbtn_list.append(grid_crop.get_child_at(3, 2) as Gtk.SpinButton); // bottom
			sbtn_list.append(grid_crop.get_child_at(1, 1) as Gtk.SpinButton); // left

			sbtn_list.foreach ((sbtn) => {
				var adjust = sbtn.get_adjustment() as Gtk.Adjustment;
				int temp = int.parse( (adjust.get_value()).to_string() );
				
				temp_array[i] = temp;
				i++;
			});
			
			crop.top = temp_array[0];
			crop.right = temp_array[1];
			crop.bottom = temp_array[2];
			crop.left = temp_array[3];

			/* Note: no access on builder objects ?! -> therefore signal 
			 * on_btn_yes_clicked_released was added */
		}

		
		[CCode (cname="on_btn_yes_released", instance_pos=-1)]
		protected void on_btn_yes_released(Gtk.Button button, Gtk.Grid grid_res){
			stdout.printf("button released\n");
			update_resolution_without_builder(grid_res);

			// destroy infobar
			var box = button.get_parent() as Gtk.Box;
			var infbar_res_aa = box.get_parent();
			var infbar_res = infbar_res_aa.get_parent();
			infbar_res.destroy();
		}

		[CCode (cname="on_btn_no_released", instance_pos=-1)]
		protected void on_btn_no_released (Gtk.Button button, 
		                                   Gtk.InfoBar infbar_res){
			update_resolution_on_cropping=false;	
			question_was_asked=true;
			
			infbar_res.destroy();
		}		

		[CCode (cname="on_adjust_croptop_value_changed", instance_pos=-1)]
		protected void on_adjust_croptop_value_changed (Gtk.Adjustment adjust){
			if(update_resolution_on_cropping==true){
				int temp = int.parse( (adjust.get_value().to_string()) );
				crop.top = temp;
				update_resolution();
			}
		}

		[CCode (cname="on_adjust_cropright_value_changed", instance_pos=-1)]
		protected void on_adjust_cropright_value_changed (Gtk.Adjustment adjust){
			if(update_resolution_on_cropping==true){
				int temp = int.parse( (adjust.get_value().to_string()) );
				crop.right = temp;
				update_resolution();
			}
		}

		[CCode (cname="on_adjust_cropbottom_value_changed", instance_pos=-1)]
		protected void on_adjust_cropbottom_value_changed (Gtk.Adjustment adjust){
			if(update_resolution_on_cropping==true){
				int temp = int.parse( (adjust.get_value().to_string()) );
				crop.bottom = temp;
				update_resolution();
			}
		}

		[CCode (cname="on_adjust_cropleft_value_changed", instance_pos=-1)]
		protected void on_adjust_cropleft_value_changed (Gtk.Adjustment adjust){
			if(update_resolution_on_cropping==true){
				int temp = int.parse( (adjust.get_value().to_string()) );
				crop.left = temp;
				update_resolution();
			}
		}

	/* methods for the video chooser button */
		[CCode (cname="on_btn_show_info_clicked", instance_pos=-1)]
		public void on_btn_show_info_clicked (Gtk.Button sender){
			infobar.destroy(); // lowpriority FIXME: raises Gtk-Criticals if no infobar
			built_infbar_info_layout();
			var object = new Json.Object();
			string[] required_videoinfo = {"width", "height", "codec", "framerate"};
			string[] required_audioinfo = {"codec", "samplerate"};
			string[] required_otherinfo = {"duration", "bitrate", "size"};
			string selection;
			string info;
			string previous;
			string examplefile;
			var targetfield = builder.get_object("e_basics0") as Gtk.Entry;
			var box = builder.get_object ("box_on_top_of_sbar") as Gtk.Box;
			box.show();

			// show the infobox
			box.pack_end(infobar, true, true, 5);
			
			selection = get_file();
			
			// provide a example output file path
			examplefile = selection.slice(0, selection.length - 5) + ".ogv";
			targetfield.set_text(examplefile);			

			object = get_parser_object (selection);

			if (object == null){
				infobar.destroy();
				built_infbar_layout(Gtk.MessageType.ERROR, "Looks like the ffmpeg2theora --info " +
				                          "command is not working correctly! \n" +
										  "Please make sure ffmpeg2theora is installed.");
				return;
			}
			foreach (string vtype in required_videoinfo) {
				info = get_specific_info_of_source(object, "video", vtype);
				previous = lbl_video.get_text();
				if (vtype == "width"){
					original_width = int.parse(info);
					lbl_video.set_text("Video\n Resolution: " + info);
				}
				else if (vtype != "height")
					lbl_video.set_text(previous + "\n " + vtype + ": " + info);
				else{
					original_height = int.parse(info);
					lbl_video.set_text(previous + "x" + info);
				}
			}
			lbl_audio.set_text ("Audio");
			foreach (string atype in required_audioinfo) {
				info = get_specific_info_of_source(object, "audio", atype);
				previous = lbl_audio.get_text();
				lbl_audio.set_text(previous + "\n " + atype + ": " + info);
			}
			lbl_other.set_text ("Other Details");
			foreach (string otype in required_otherinfo) {
				info = get_specific_info_of_source(object, otype, "");
				previous = lbl_other.get_text();
				lbl_other.set_text(previous + "\n " + otype + ": " + info);
			}
			if (original_width > 0){
				error_infbar.destroy();
				
				lbl_other.show();
				infobar.show();

				// set cropping sbtns to 0
				string[] sbtns = {"adjust_crop0", "adjust_crop1", "adjust_crop2", "adjust_crop3"};
				foreach (string spinbutton in sbtns){
					var crop_sbtn = builder.get_object(spinbutton) as Gtk.Adjustment;
					crop_sbtn.set_value(0);
				}	
				update_resolution();

				//update_endtime via class variables min and sec
				var adjust = builder.get_object("adjust_basics1") as Gtk.Adjustment;
				var entry = builder.get_object("e_end_min") as Gtk.Entry;
				adjust.set_value(sec);
				entry.set_text(min.to_string("%d"));
			}
			else{ // show a error message
				infobar.destroy();
				built_infbar_layout(Gtk.MessageType.ERROR, "No valid video file found! \n" +
					"Possible reasons: video codec unknown or malformed video file!\n");
			}
		}

	/* when a video was selected, update the video resolution */
		private void update_resolution(){
			var height_sbtn = builder.get_object("scale_quality4") as Gtk.SpinButton;
			var scale = builder.get_object("scale_scale") as Gtk.Scale;
			var width_entry = builder.get_object("e_quality0") as Gtk.Entry;
			
			update_resolution_values(height_sbtn, scale, width_entry);
		}

		/* in case the calling function has no access on builder */
		private void update_resolution_without_builder(Gtk.Grid grid_res){
			var height_sbtn = grid_res.get_child_at(1, 1) as Gtk.SpinButton;
			var scale = grid_res.get_child_at(0, 0) as Gtk.Scale;
			var width_entry = grid_res.get_child_at(0, 1) as Gtk.Entry;

			update_resolution_values(height_sbtn, scale, width_entry);
		}

		private void update_resolution_values(Gtk.SpinButton height_sbtn, 
		                                Gtk.Scale scale, Gtk.Entry width_entry){
			/* use the cropping settings */
			_height = original_height - crop.top - crop.bottom;
			_width = original_width - crop.right - crop.left;
			
		/* set maximum resolution height */
			var adjust = height_sbtn.get_adjustment() as Gtk.Adjustment;
			adjust.set_upper(_height);

		/* get scale info */
			
			string scale_info = (scale.get_value()*1000).to_string();
			
		/* update resolution settings (the entry and sbtn) */
			int new_width = (int.parse(scale_info)*(_width)/1000);
			int new_height = (int.parse(scale_info)*(_height)/1000);
			width_entry.set_text(new_width.to_string("%d"));
			adjust.set_value(new_height);
		}

		/* infobar about different video file information is created in the code, 
		 * without GtkBuilder */
		private void built_infbar_info_layout()
		{
			//var show_info_button = builder.get_object("btn_show_info") as Button;
			infobar = new Gtk.InfoBar();
			var infobar_content = infobar.get_content_area () as Gtk.Container;
			var grid_video = new Gtk.Grid();
			var grid_audio = new Gtk.Grid();
			var grid_other = new Gtk.Grid();

			//show_info_button.set_sensitive(false);
		
		
			lbl_video = new Gtk.Label("");
			lbl_audio = new Gtk.Label("");
			lbl_other = new Gtk.Label("");
			
			// left, top, width, height 
			grid_video.attach(lbl_video, 0, 0, 1, 4);
			grid_video.attach(lbl_audio, 1, 0, 1, 3);
			grid_other.attach(lbl_other, 2, 0, 1, 4);
			infobar.show();
			grid_video.show();
			lbl_video.show();
			grid_audio.show();
			lbl_audio.show();
			grid_other.show();
			lbl_other.show();
			infobar.add_button ("Hide", Gtk.ResponseType.CLOSE);

			infobar_content.add(grid_video);
			infobar_content.add(grid_audio);
			infobar_content.add(grid_other);

			// if user clicks the hide btn, destroy it
			infobar.response.connect (() => {
				infobar.destroy();
			});
		}	

		

		/* queries the file from fbtn */
		private string get_file(){
			// find out which file got selected
			var fbtn = this.builder.get_object("fbtn_basics0") as Gtk.FileChooserButton;
			return fbtn.get_filename(); /* Note: get_uri() no the other hand does not 
										 * work correctly, only sometimes! 
										 * (issues with some chars) */
		}

		/* returns the info of the video file as Json.Object */
		private Json.Object get_parser_object(string source){
			string info;
			string command = "ffmpeg2theora --info " + "'" + source + "'";
			stdout.printf("show info command: %s\n", command);
			NSCommand.Execution process = new NSCommand.Execution();
			process.sync_command(command);
			info = process.info;
			// parse string via Json.Parser
			try{
				var parser = new Json.Parser ();
				//NSFile.cd(PROFILE_PATH, true);
				parser.load_from_data(info, -1);
				
				var root_object = parser.get_root().get_object ();
				return root_object;
			} catch (Error e) {
				stderr.printf ("Error: Something went wrong...\n");
			} 
			var dont_throw = new Json.Object();
			return dont_throw;			
		}

		/* evaluate the JSON output from the f2t --info command */
		private string get_specific_info_of_source(Json.Object root_o, 
		                                             string category, string type="")
		{
			string info;
			if (type == ""){ // all outside of audio, video
				double val;
				val = root_o.get_double_member(category);
				if (category == "size"){ 
					double bitrate;
					double seconds;
					double size;
					bitrate = root_o.get_double_member("bitrate");
					seconds = root_o.get_double_member("duration");
					size = bitrate*seconds/8.0/1000.0;
					info = size.to_string();
					return cut_strings_of_doubles(info, " MB");	
				}
				if (category == "duration"){
					min = (int)(val/60);
					sec = (int)val - min*60;
					return min.to_string("%d") + " min " + sec.to_string("%d") + " sec"; 					
				}
				else{ // category bitrate
					info = val.to_string();
					return cut_strings_of_doubles(info, " kb/s");
				}
			}
			else{
				var item = root_o.get_array_member(category).get_object_element(0);
				info = item.get_string_member(type);
				if (info == null) info = item.get_int_member(type).to_string("%d");
				if (info == null) info = item.get_double_member(type).to_string();
				return info; 
			}
		} 

		private string cut_strings_of_doubles(string info, string additional)
		{
			int count;
			count = info.char_count();
			return info.slice(0, count-12) + additional;	
		}

	/* methods used with the help button  */
		/* hide infobars, then show a new box with textview, show filter 
		 *	and close button; textbuffer will show ffmpeg2theora --help */
		[CCode (cname="on_btn_help_clicked", instance_pos=-1)]
		public void on_btn_help_clicked (Gtk.Button sender) {
			/* lowpriority FIXME: a ToggleButton implementation might have been better */
			var box = builder.get_object("box_on_top_of_sbar") as Gtk.Box;
			var children = box.get_children();
			children.foreach((a) => { 
				 a.destroy();
			});
			var advice_button = builder.get_object("btn_advice") as Gtk.Button;
			var show_info_button = builder.get_object("btn_show_info") as Gtk.Button;
			advice_button.set_sensitive(true);
			show_info_button.set_sensitive(true);
	

			NSCommand.Execution process = new NSCommand.Execution();


			if (active_tab == "other"){
				var ibar = builder.get_object("infbar_color") as Gtk.InfoBar;
				ibar.hide();
				ibar = builder.get_object("infbar_terminal") as Gtk.InfoBar;
				ibar.hide();
				ibar = builder.get_object("infbar_profiles") as Gtk.InfoBar;
				ibar.hide();
			}

			else{
				var ibar = builder.get_object("infbar_" + active_tab) as Gtk.InfoBar;
				ibar.hide();
			}
			string info;
			var infobar_f2theora = builder.get_object("infbar_f2theora_help") as Gtk.InfoBar;
			var textbuffer_f2theora = builder.get_object("txb_f2theora_help") as Gtk.TextBuffer;
			var toggle_f2theora = builder.get_object("tbtn_show_filters") as Gtk.ToggleButton;
			//stdout.printf("%s", info);
			if (toggle_f2theora.get_active() == false){
				process.sync_command("ffmpeg2theora --help");
			}
			else{
				process.sync_command("ffmpeg2theora --pp help");
			}
			info = process.info;
			textbuffer_f2theora.set_text(info);	
			infobar_f2theora.show();
		}

		[CCode (cname="on_tbtn_show_filters_toggled", instance_pos=-1)]
		public void on_tbtn_show_filters_toggled (Gtk.ToggleButton sender) {
			var textbuffer_f2theora = builder.get_object("txb_f2theora_help") as Gtk.TextBuffer;
			string info;
			NSCommand.Execution process = new NSCommand.Execution();
			if (sender.get_active() == true){
				process.sync_command("ffmpeg2theora --pp help");
			}
			else{
				process.sync_command("ffmpeg2theora --help");
			}	
			info = process.info;
			textbuffer_f2theora.set_text(info);	
			
		}

	/* method for the advice button */
		[CCode (cname="on_btn_advice_clicked", instance_pos=-1)]
		public void on_btn_advice_clicked (Gtk.Button sender) {
			/* lowpriority FIXME: a ToggleButton implementation might have been better */
			sender.set_sensitive (false);
			var advice_infobar = new Gtk.InfoBar() as Gtk.InfoBar;
			var box = builder.get_object ("box_on_top_of_sbar") as Gtk.Box;
			var idea = new Gtk.Image.from_stock (Gtk.Stock.DIALOG_INFO, Gtk.IconSize.DIALOG);
			var infobar_content = advice_infobar.get_content_area () as Gtk.Container;
			box.show();
		

			advice_infobar.response.connect (() => {
				advice_infobar.destroy();
				sender.set_sensitive (true);														 
			});

			advice_infobar.add_button ("Hide", Gtk.ResponseType.CLOSE);

			infobar_content.add(idea);
			infobar_content.add(advice_label);
		
			// show the infobox
			box.pack_end(advice_infobar, true, true, 5);

			idea.show();
			advice_label.show();
			advice_infobar.show();
		}		
	}	

}