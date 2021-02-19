import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences localStorage;
int lastID;

const TagKeyPrefix = 'tag';
const DailyTagPrefix = 'dailyTag';

const ValidTagsKey = 'validTags';

const LastIDKey = 'lastID';

const ValidDatesKey = 'validDates';

DateFormat formatter = DateFormat('yyyy-MM-dd');
