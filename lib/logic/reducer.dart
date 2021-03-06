import 'package:firebase_database/firebase_database.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';

ReduxState reduce(ReduxState state, action) {
  List<WeightEntry> entries = reduceEntries(state, action);
  String unit = reduceUnit(state, action);
  RemovedEntryState removedEntryState = reduceRemovedEntryState(state, action);
  WeightEntryDialogReduxState weightEntryDialogState =
  reduceWeightEntryDialogState(state, action);
  FirebaseState firebaseState = reduceFirebaseState(state, action);
  MainPageReduxState mainPageState = reduceMainPageState(state, action);
  return new ReduxState(
      entries: entries,
      unit: unit,
      removedEntryState: removedEntryState,
      weightEntryDialogState: weightEntryDialogState,
      firebaseState: firebaseState,
      mainPageState: mainPageState);
}

String reduceUnit(ReduxState reduxState, action) {
  String unit = reduxState.unit;
  if (action is OnUnitChangedAction) {
    unit = action.unit;
  }
  return unit;
}

MainPageReduxState reduceMainPageState(ReduxState reduxState, action) {
  MainPageReduxState newMainPageState = reduxState.mainPageState;
  if (action is AcceptEntryAddedAction) {
    newMainPageState = newMainPageState.copyWith(hasEntryBeenAdded: false);
  } else if (action is OnAddedAction) {
    newMainPageState = newMainPageState.copyWith(hasEntryBeenAdded: true);
  }
  return newMainPageState;
}

FirebaseState reduceFirebaseState(ReduxState reduxState, action) {
  FirebaseState newState = reduxState.firebaseState;
  if (action is InitAction) {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  } else if (action is UserLoadedAction) {
    newState = newState.copyWith(firebaseUser: action.firebaseUser);
  } else if (action is AddDatabaseReferenceAction) {
    newState = newState.copyWith(mainReference: action.databaseReference);
  }
  return newState;
}

RemovedEntryState reduceRemovedEntryState(ReduxState reduxState, action) {
  RemovedEntryState newState = reduxState.removedEntryState;
  if (action is AcceptEntryRemovalAction) {
    newState = newState.copyWith(hasEntryBeenRemoved: false);
  } else if (action is OnRemovedAction) {
    newState = newState.copyWith(
        hasEntryBeenRemoved: true,
        lastRemovedEntry: new WeightEntry.fromSnapshot(action.event.snapshot));
  }
  return newState;
}

WeightEntryDialogReduxState reduceWeightEntryDialogState(ReduxState reduxState,
    action) {
  WeightEntryDialogReduxState newState = reduxState.weightEntryDialogState;
  if (action is UpdateActiveWeightEntry) {
    newState = newState.copyWith(
        activeEntry: new WeightEntry.copy(action.weightEntry));
  } else if (action is OpenAddEntryDialog) {
    newState = newState.copyWith(
        activeEntry: new WeightEntry(
            new DateTime.now(),
            reduxState.entries.isEmpty ? 70.0 : reduxState.entries.first.weight,
            null),
        isEditMode: false);
  } else if (action is OpenEditEntryDialog) {
    newState =
        newState.copyWith(activeEntry: action.weightEntry, isEditMode: true);
  }
  return newState;
}

List<WeightEntry> reduceEntries(ReduxState state, action) {
  List<WeightEntry> entries = new List.from(state.entries);
  if (action is OnAddedAction) {
    entries
      ..add(new WeightEntry.fromSnapshot(action.event.snapshot))
      ..sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime));
  } else if (action is OnChangedAction) {
    WeightEntry newValue = new WeightEntry.fromSnapshot(action.event.snapshot);
    WeightEntry oldValue =
    entries.singleWhere((entry) => entry.key == newValue.key);
    entries
      ..[entries.indexOf(oldValue)] = newValue
      ..sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime));
  } else if (action is OnRemovedAction) {
    WeightEntry removedEntry = state.entries
        .singleWhere((entry) => entry.key == action.event.snapshot.key);
    entries
      ..remove(removedEntry)
      ..sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime));
  }
  return entries;
}
