#library('dartemis');

#import('dart:coreimpl');

#source('dartemis/utils/bag.dart');
#source('dartemis/utils/fast_lookup_table.dart');
#source('dartemis/utils/fast_math.dart');
#source('dartemis/utils/immutable_bag.dart');
#source('dartemis/utils/timer.dart');
#source('dartemis/utils/utils.dart');


main() {
  print(Utils.getRotatedX(1.0, 2.0, 3.0, 4.0, 5.0));
}