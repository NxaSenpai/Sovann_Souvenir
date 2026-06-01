import 'package:flutter_riverpod/legacy.dart';
import '../models/branch.dart';

final selectedBranchProvider = StateProvider<Branch?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final filterOpenOnlyProvider = StateProvider<bool>((ref) => false);
