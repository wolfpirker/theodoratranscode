using GLib;

namespace NSWidgets{
	// set Widget parameters to reflect the values from file
	/* the namespace might be confusing, actually this class has only access on widgets
	 * via the builder argument */
	public class Adjustment : Object
	{
		private static NSFile.Loading loading;
		private static Variant widgets_to_check;

		private uint8 index=0;

		public Adjustment(string profile, bool startup){
			if (startup==false)	prepare_adjustment_to_profile(profile);	
			else prepare_adjustment_mode1(profile); // profile == PROFILE_MODE1
		}

		/* mode 2, profiles */
		protected void prepare_adjustment_to_profile(string profilename){
			loading = new NSFile.Loading("profile_" + profilename + ".json"); 
			widgets_to_check = NSWidgets.Query.widgets_to_check(2);
			loading.create_valuelist(2);
			loading.valuelist.first();
		}

		/* mode 1, settings to load when applications starts */
		protected void prepare_adjustment_mode1(string profile){
			loading = new NSFile.Loading(profile + ".json"); 
			widgets_to_check = NSWidgets.Query.widgets_to_check(1);
			loading.create_valuelist(1);
			loading.valuelist.first();
		}

		public void adjust_widgets(Gtk.Builder _builder){
			Variant? val = null;
			string? key = null;
			VariantIter iter = widgets_to_check.iterator();

			while(iter.next("{sv}", &key, &val)){
				adjust_widgets_of_category(_builder, key, val);
			} 
		}

		protected void adjust_widgets_of_category(Gtk.Builder _builder, 
		                                 string category, Variant widgettypes){
			/* use the valuelist which combines all category values
			 * do index+=1 if queried widget exists, if not stop with the particular
			 * widgettype */
			uint8 i=0;
			
			while (i<widgettypes.n_children ()){
				string type = widgettypes.get_child_value(i).get_string();

				switch(type){ /* types to check: scale, e (/ce), cbtn */
					case "scale":
						Gtk.Adjustment adjust;
						uint8 j=0;
						while(true){
							adjust = _builder.get_object("adjust_" + category + j.to_string("%d")) as Gtk.Adjustment;
							if (adjust==null) break;
							adjust.set_value( double.parse(loading.valuelist.nth_data(index)) );
							j++;
							index++;
						}
						break;
					case "e":
					case "ce":
						Gtk.Entry entry;
						uint8 j=0;
						while(true){
							entry = _builder.get_object(type + "_" + category + j.to_string("%d")) as Gtk.Entry;
							if (entry==null) break;
							entry.set_text(loading.valuelist.nth_data(index));
							j++;
							index++;
						}
						break;
					case "cbtn":
						Gtk.ToggleButton cbtn;
						uint8 j=0;
						while(true){
							cbtn = _builder.get_object(type + "_" + category + j.to_string("%d")) as Gtk.ToggleButton;
							if (cbtn==null) break;
							cbtn.set_active( bool.parse(loading.valuelist.nth_data(index)) );
							j++;
							index++;
						}
						break;						
					default:
						stdout.printf("widgettype %s not adjusted!\n", type);
						break;
				}
				
				i++;
			}
		}	
	}
}