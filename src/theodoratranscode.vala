/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * theodoratranscode.c
 * Copyright (C) 2013 Wolfgang Pirker <w_pirker@gmx.de>
 * 
 * theodoratranscode is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * theodoratranscode is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;

public class Main : Gtk.Application
{
	protected Gtk.Builder builder; 
	public const string LAST_PROFILE = "most recent";
	public const string PROFILE_PATH = "/.local/share/theodora-transcode/"; 
	public const string PROFILE_MODE1 = "config_last";

	/* following mostly used in the Feedback class */
	protected Gtk.Label advice_label;
	protected Gtk.InfoBar infobar; // -> shows video info
	protected Gtk.InfoBar error_infbar;	// -> a general infobar, of any type
	protected Gtk.Label lbl_video;
	protected Gtk.Label lbl_audio;
	protected Gtk.Label lbl_other;

	bool gtk_builder_without_infobars = false;

	private string _active_tab = "basics";
	public string active_tab{
		get {return _active_tab;}
		set {_active_tab=value;}
	}

	/* 
	 * Uncomment this line when you are done testing and building a tarball
	 * or installing
	 */
	const string UI_FILE = Config.PACKAGE_DATA_DIR + "/" + "theodoratranscode.ui";
	//const string UI_FILE = "src/theodoratranscode.ui";

	/* for Debian 7 compatibility: */
	//const string UI_FILE = Config.PACKAGE_DATA_DIR + "/" + "theodoratranscode_debian.ui";
	//const string UI_FILE = "src/theodoratranscode_debian.ui";
	
	/* ANJUTA: Widgets declaration for theodoratranscode.ui - DO NOT REMOVE */
	
	public Main (){

		try { 
			advice_label = new Gtk.Label("In case a filename is entered as destination, the file will " +
			                      "be stored in your home user directory.\n\n" +
								  "Tips on Subtitle section\n" +
			                      "* to specify more than one subtitle, " +
			                      "you can do this via Other→parameters.\n" +
			                      "if you leave the encoding field blank, UTF-8 will be " +
								  "used, which works mostly.\n" +
								  "For a list of supported encodings you can use the " + 
			                      "'iconv -l' command.\n.");
			builder = new Gtk.Builder() as Gtk.Builder;
			this.builder.add_from_file (UI_FILE);
			this.builder.connect_signals (this);

			var window = this.builder.get_object ("window") as Gtk.Window;
			/* ANJUTA: Widgets initialization for theoraconvert.ui - DO NOT REMOVE */

			window.show_all();

			NSFile.cd(PROFILE_PATH, true);
			if ( FileUtils.test(PROFILE_MODE1 + ".json", FileTest.IS_REGULAR) == true ){
				/* adjust widget values to the ones used last time */
				var adjust = new NSWidgets.Adjustment(PROFILE_MODE1, true);
				adjust.adjust_widgets(builder);
			}
		} 
		catch (Error e) {
			stderr.printf ("Could not load UI: %s\n", e.message);
		}

		/* test if the GUI with or without infobars is used */
		var test_infobar = builder.get_object("infbar_basics") as Gtk.InfoBar;
		if (test_infobar == null) gtk_builder_without_infobars = true;
	}

	/* create a general info, warning or error infobar */
	protected void built_infbar_layout(Gtk.MessageType type, string message, string button=""){
		if (error_infbar != null) error_infbar.destroy(); 
		
		var error_image = new Gtk.Image.from_stock(Gtk.Stock.DIALOG_INFO, 
			                                           Gtk.IconSize.DIALOG);
		if (type == Gtk.MessageType.ERROR){
			error_image = new Gtk.Image.from_stock(Gtk.Stock.DIALOG_ERROR, 
			                                           Gtk.IconSize.DIALOG);
		}
		else if (type == Gtk.MessageType.WARNING){
			error_image = new Gtk.Image.from_stock(Gtk.Stock.DIALOG_WARNING, 
			                                           Gtk.IconSize.DIALOG);
		}
		error_infbar = new Gtk.InfoBar() as Gtk.InfoBar;
		var error_infbar_ca = error_infbar.get_content_area () as Gtk.Container;
		var error_label = new Gtk.Label(message);
		error_infbar.set_message_type(type);

		error_infbar_ca.add(error_image);
		error_infbar_ca.add(error_label);

		var box = builder.get_object ("box_on_top_of_sbar") as Gtk.Box;
		box.show();

		// show the infobox
		box.pack_end(error_infbar, true, true, 5);
		error_image.show();
		error_label.show();
		error_infbar.show();

		if (button != ""){
			error_infbar.add_button ("Hide", Gtk.ResponseType.CLOSE);

			error_infbar.response.connect (() => {
				error_infbar.destroy();													 
			});
		}
	}

	static int main (string[] args) 
	{
		Gtk.init (ref args);
		var app = new Main ();

		Gtk.main ();
		
		return 0;
	}
}
