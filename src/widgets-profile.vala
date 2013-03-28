using GLib;

namespace NSWidgets{
	/* FIXME: ProfileNames has nothing to do with widgets! -> find another place */
	class ProfileNames : Object{
		private List<string> _profiles;
		public List<string> profiles{
			get {return _profiles;}
		}

		public ProfileNames(){
			update();
		}

		private void update(){
			_profiles = NSFile.dir(Main.PROFILE_PATH, true, "profile_", ".json");					
		}
	}

	
	class Profile : Main{
		
		private static string previous_name; 

		private static int previously_active = 0-1;

		public Profile(){
			stdout.printf("Profile class\n\n");
		}

		[CCode (cname="on_e_profile_icon_press", instance_pos=-1)]
		public void on_e_profile_icon_press(Gtk.Entry entry, 
		                           Gtk.EntryIconPosition pos){
			var cboxt = entry.get_parent() as Gtk.ComboBoxText;

			// the left icon was pressed, make the entry modifieable
			if (pos == Gtk.EntryIconPosition.PRIMARY){
				previous_name = entry.get_text();
				entry.set_icon_sensitive (Gtk.EntryIconPosition.PRIMARY, false);
				entry.set_can_focus(true);
				entry.grab_focus();
				entry.set_icon_sensitive (Gtk.EntryIconPosition.SECONDARY, true);
				/* Note: access on builder does not work, because of the extra user 
				 * data argument! -> FIXME: push statusbar message */ 
			}
			else{
				entry.activate(); // on_e_profile_activate(entry) would not work!!!
			}
		}

		[CCode (cname="on_e_profile_activate", instance_pos=-1)]
		public void on_e_profile_activate(Gtk.Entry entry){
			var button = builder.get_object("btn_save_profile") as Gtk.Button;
			entry.set_icon_sensitive (Gtk.EntryIconPosition.PRIMARY, true);
			entry.set_can_focus(false);
			entry.set_icon_sensitive (Gtk.EntryIconPosition.SECONDARY, false);

			button.clicked();
			button.grab_focus();
			if (previous_name != ""){
				delete_profile(previous_name);
				push_statusbar_message("renamed profile " + previous_name);
			}
			var cboxt = entry.get_parent() as Gtk.ComboBoxText;
			update_cboxt(cboxt);
			
		}
		
		protected void delete_profile(string profile){
			NSFile.cd(PROFILE_PATH, true);
			FileUtils.remove("profile_" + profile + ".json");
			var profiles = new NSWidgets.ProfileNames();
			// TODO: perhaps Error handling
		}

		[CCode (cname="on_btn_delete_profile_clicked", instance_pos=-1)]
		public void on_btn_delete_profile_clicked (Gtk.Button sender, 
		                                           Gtk.Entry entry) {
			int auswahl = 0;
			var cboxt = entry.get_parent() as Gtk.ComboBoxText;
			delete_profile(entry.get_text());
			update_cboxt(cboxt);
			string removed = entry.get_text();
			entry.set_text("");
			//push_statusbar_message("removed profile: " + removed);
		}

		public void update_cboxt (Gtk.ComboBoxText cboxt) {
			/* update the profiles combobox */
			var profilenames = new NSWidgets.ProfileNames();
			cboxt.remove_all();
			profilenames.profiles.foreach((profile) => {
				string clean_profilename = profile.slice(8, profile.length - 5);
				cboxt.append_text(clean_profilename);					  	
			});
		}

		[CCode (cname="on_infbar_profiles_show", instance_pos=-1)]
		public void on_infbar_profiles_show (Gtk.InfoBar infbar_profiles){
			var cboxt = builder.get_object("cboxt_profile") as Gtk.ComboBoxText;
			update_cboxt(cboxt);
		}

		[CCode (cname="on_btn_new_profile_clicked", instance_pos=-1)]
		public void on_btn_new_profile_clicked (Gtk.Button sender, 
		                                           Gtk.Entry entry) {
			entry.set_text("");
			on_e_profile_icon_press(entry, Gtk.EntryIconPosition.PRIMARY);
			string profile = entry.get_text();
			//push_statusbar_message("created profile '" + profile + "'.");
		}

		[CCode (cname="on_cboxt_profile_changed", instance_pos=-1)]
		public void on_cboxt_profile_changed (Gtk.ComboBox cbox) {
			var e = builder.get_object("e_profile") as Gtk.Entry;
			string profile = e.get_text();
			int now_active = cbox.get_active();
			if ((now_active != previously_active) && (now_active != -1)){ 
				if ( FileUtils.test("profile_" + profile + ".json", FileTest.IS_REGULAR) == true ){
					var adjust = new NSWidgets.Adjustment(profile, false); 
					adjust.adjust_widgets(builder);
					push_statusbar_message("loaded profile: " + profile);
				}
			previously_active = now_active;
			}
		}

		private void push_statusbar_message(string message){
			var sbar = builder.get_object("sbar") as Gtk.Statusbar;
			sbar.push(0, message);
			sbar.set_tooltip_text("");
		}
	}

}