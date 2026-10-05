import 'models/location_model_test.dart' as location_model_test;
import 'domain/place_search_test.dart' as place_search_test;
import 'presentation/location_picker_theme_test.dart'
    as location_picker_theme_test;
import 'presentation/location_picker_config_test.dart'
    as location_picker_config_test;
import 'presentation/location_picker_strings_test.dart'
    as location_picker_strings_test;
import 'presentation/view/location_map_preview_test.dart'
    as location_map_preview_test;
import 'presentation/view/location_picker_view_test.dart'
    as location_picker_view_test;
import 'presentation/view/widgets/map_action_controls_test.dart'
    as map_action_controls_test;
import 'presentation/view/widgets/map_confirm_button_test.dart'
    as map_confirm_button_test;

void main() {
  location_model_test.main();
  place_search_test.main();
  location_picker_theme_test.main();
  location_picker_config_test.main();
  location_picker_strings_test.main();
  location_map_preview_test.main();
  location_picker_view_test.main();
  map_action_controls_test.main();
  map_confirm_button_test.main();
}
