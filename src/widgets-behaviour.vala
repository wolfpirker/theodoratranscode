using GLib;

namespace NSWidgets{
	// sets widget behaviour: visibility, sensitivity etc.
	public class Behaviour : Main
	{				
		public Behaviour()
		{		
		}

	/* widgets below the basics category */
		[CCode (cname="on_sbtn_time_changed", instance_pos=-1)]
		protected void on_sbtn_time_changed(Gtk.SpinButton sbtn, Gtk.Entry entry){
			if (60 <= sbtn.get_value_as_int()){
				int minutes;
				sbtn.set_value(0);
				minutes = int.parse(entry.get_text()) + 1;
				entry.set_text (minutes.to_string ("%d"));			
			}
			else if (0 > sbtn.get_value_as_int()){
				int minutes;
				sbtn.set_value(59);
				minutes = int.parse(entry.get_text()) - 1;
				if (0 > minutes) minutes = 0;
				entry.set_text (minutes.to_string ("%d"));
			}		
		}	

		[CCode (cname="on_fbtn_basics1_file_set", instance_pos=-1)]
		protected void on_fbtn_basics1_file_set (Gtk.FileChooserButton fbtn, 
		                                         Gtk.RadioButton rbtn){
			rbtn.set_active(true);
		}

	/* widgets below the quality category */
		[CCode (cname="on_adjust_quality_value_changed_unset", instance_pos=-1)]
		protected void on_adjust_quality_value_changed_unset (Gtk.Adjustment adjust, 
		                                                      Gtk.CheckButton cbtn){
			cbtn.set_active(false);
		}

		[CCode (cname="on_adjust_quality_value_changed_set", instance_pos=-1)]
		protected void on_adjust_quality_value_changed_set (Gtk.Adjustment adjust, 
		                                                      Gtk.CheckButton cbtn){
			cbtn.set_active(true);
		}

		[CCode (cname="on_cbtn_quality0_toggled", instance_pos=-1)]
		protected void on_cbtn_quality0_toggled (Gtk.ToggleButton cbtn, 
		                                                      Gtk.CheckButton cbtn_2pass){
			var quality_grid = cbtn.get_parent() as Gtk.Grid;
			var cbtn_soft_target = quality_grid.get_child_at(1, 7) as Gtk.CheckButton;
			if (cbtn.get_active() == true){
				cbtn_2pass.set_sensitive(true);
				cbtn_soft_target.set_sensitive(true);
				cbtn_soft_target.set_active(true); // with specified Bitrate, make it default
			}
			else{
				cbtn_2pass.set_sensitive(false);
				cbtn_2pass.set_active(false);
				cbtn_soft_target.set_sensitive(false);
				cbtn_soft_target.set_active(false);
			}
		}

		[CCode (cname="on_scale_quality4_value_changed", instance_pos=-1)]
		protected void on_scale_quality4_value_changed (Gtk.SpinButton sbtn, 
		                                         Gtk.Grid grid){
			var entry = grid.get_child_at(0, 1) as Gtk.Entry;
			var adjust = sbtn.get_adjustment() as Gtk.Adjustment;
			int height = sbtn.get_value_as_int();
			int new_width;
			if (NSWidgets.Feedback.width != 0){
				var scale_scale = grid.get_child_at(0, 0) as Gtk.Scale;
				new_width = NSWidgets.Feedback.width*height/NSWidgets.Feedback.height;
				if (new_width %2 == 1) new_width--; // only show even widths
				/* move the scale slider, make sure on_scale_scale_value_changed
				 * doesn't change any values in width_entry or height_sbtn */
				if (scale_scale.has_focus == false){
					var adjust_scale = scale_scale.get_adjustment() as Gtk.Adjustment;
					int source_height = NSWidgets.Feedback.height;
					/*int source_width = int.parse(NSWidgets.Feedback.width);
					int new_val = 1000*new_width*height/source_height/source_width;*/
					int new_val = 1000*height/source_height;
					adjust_scale.set_value((double.parse((new_val).to_string("%d"))
					                        /1000));
				}
			}
			else new_width = height*16/9;
			entry.set_text(new_width.to_string("%d"));
		}

		[CCode (cname="on_scale_scale_value_changed", instance_pos=-1)]
		protected void on_scale_scale_value_changed(Gtk.Scale scale,
		                                               Gtk.Grid grid){
			// FIXME: consider also croptop, -rigth, -bottom, -left!
			if (scale.has_focus == false) return; 
			if (NSWidgets.Feedback.width != 0){
				int width = NSWidgets.Feedback.width; // widgth, height
				int height = NSWidgets.Feedback.height; // of source
				string info = (scale.get_value()*1000).to_string();
				int share = int.parse(info);
				width = (width)*share/1000; // find new width, heigth
				height = (height)*share/1000;
				if (width %2 == 1) width--; // both should be even
				if (height %2 == 1) height--;
				var width_e = grid.get_child_at(0, 1) as Gtk.Entry;
				var height_sbtn = grid.get_child_at(1, 1) as Gtk.SpinButton;
				width_e.set_text(width.to_string ("%d"));
				height_sbtn.set_text(height.to_string("%d"));
			}
			
					
		}

	/* widgets below crop category -> all this moved to the feedback class! */
				
	/* widgets always visible */
		[CCode (cname="on_rbtn_basics_toggled", instance_pos=-1)]
		public void on_rbtn_basics_toggled (Gtk.ToggleButton sender) 
		{
			var ibar = this.builder.get_object("infbar_basics") as Gtk.InfoBar;
			active_tab = "basics";
			this.hide_infoboxes();
			ibar.show();
			advice_label.set_text("In case a filename is entered as target, the file will " +
			                      "be stored in your user home directory.\n\n" +
								  "Tips on Subtitle section\n" +
			                      "if you want to specify more than one subtitle, " +
			                      "you can do this via Other→parameters.\n" +
			                      "if you leave the encoding field blank, UTF-8 will be " +
								  "used, which works in most cases.\n" +
								  "For a list of supported encodings you can use the " + 
			                      "'iconv -l' command.\n.");
		}

		[CCode (cname="on_rbtn_quality_toggled", instance_pos=-1)]
		public void on_rbtn_quality_toggled (Gtk.ToggleButton sender)
		{
			var ibar = this.builder.get_object("infbar_quality") as Gtk.InfoBar;
			active_tab = "quality";
			this.hide_infoboxes();
			ibar.show();
			advice_label.set_text("* the video qualifier: use higher values for better quality (default: 6)\n" +
			                      "* the audio qualifier: use higher value for better quality (default: 1)\n" +
			                      "* as alternative to the qualifiers, it is possible to set a bitrate.\n" +
			                      "optimize: makes the quality/filesize ratio better, " +
			                      "but is a bit slower.\n" +
			                      "soft-target and two-pass can be enabled if a Video Bitrate is specified.\n" +
			                      "soft-target: less strict rate control, but with otherwise higher quality.\n" +
			                      "two-pass: slower conversion, but with higher quality.");		
		}
	
		[CCode (cname="on_rbtn_crop_toggled", instance_pos=-1)]
		public void on_rbtn_crop_toggled (Gtk.ToggleButton sender) 
		{
			var ibar = this.builder.get_object("infbar_crop") as Gtk.InfoBar;
			active_tab = "crop";
			this.hide_infoboxes();	
			ibar.show();

			advice_label.set_text("About the preview possiblity\n" +
			                      "After a click on preview the file preview.ogv is saved \n" + 
			                      "in the directory for temporary files (likely /tmp/).\n" +
			                      "With Fast preview enabled the preview will result " +
			                      "in worse\nquality and/or higher bitrate than otherwise.\n" 			                  
			                      );		
		
		}

		[CCode (cname="on_rbtn_other_toggled", instance_pos=-1)]
		public void on_rbtn_other_toggled (Gtk.ToggleButton sender) 
		{
			var ibar = this.builder.get_object("infbar_color") as Gtk.InfoBar;
			var ibar2 = this.builder.get_object("infbar_terminal") as Gtk.InfoBar;
			var ibar3 = this.builder.get_object("infbar_profiles") as Gtk.InfoBar;
			active_tab = "other";
			this.hide_infoboxes();
			ibar.show();
			ibar2.show();
			ibar3.show();

			advice_label.set_text("Contrast, Gamma and Saturation have a default value " +
			                      "of 1.0.\n" +
			                      "lower values in the color settings make the video darker" +
			                      " or in case of\nsaturation greyer.\n" +
			                      "For a list of parameters you can click on the button " +
			                      "ffmpeg2theora help.");
		}

		private void hide_infoboxes ()
		{
			string[] categories = {"infbar_basics", "infbar_quality", "infbar_crop",
				"infbar_color", "infbar_terminal", "infbar_profiles", "infbar_f2theora_help"};

			foreach (string infobox in categories)
			{
				var ibar = this.builder.get_object(infobox) as Gtk.InfoBar;
				ibar.hide();
			}
		}

		[CCode (cname="on_btn_f2theora_close_clicked", instance_pos=-1)]
		public void on_btn_f2theora_close_clicked (Gtk.Widget sender) {
			var infbar_f2theora = builder.get_object("infbar_f2theora_help") as Gtk.InfoBar;
			var current_tab_infbar = builder.get_object("infbar_" + active_tab) as Gtk.InfoBar;
			infbar_f2theora.hide();
			current_tab_infbar.show();
			if (active_tab == "other")
			{
				var ibar = builder.get_object("infbar_color") as Gtk.InfoBar;
				ibar.show();
				ibar = builder.get_object("infbar_terminal") as Gtk.InfoBar;
				ibar.show();
				ibar = builder.get_object("infbar_profiles") as Gtk.InfoBar;
				ibar.show();
			}

			else{
				var ibar = builder.get_object("infbar_" + active_tab) as Gtk.InfoBar;
				ibar.show();
			}
		}
	
	}
}