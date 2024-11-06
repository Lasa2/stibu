import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:result_type/result_type.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/currency.dart';
import 'package:stibu/common/datetime_formatter.dart';
import 'package:stibu/common/show_result_info.dart';
import 'package:stibu/main.dart';

class EventInputDialog extends StatefulWidget {
  final String title;
  final CalendarEvents? event;

  const EventInputDialog({
    super.key,
    required this.title,
    this.event,
  });

  @override
  State<EventInputDialog> createState() => _EventInputDialogState();
}

class _EventInputDialogState extends State<EventInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _title = widget.event?.title;
  late String? _description = widget.event?.description;
  late DateTime _startDate = widget.event?.start.toLocal() ?? DateTime.now();
  late DateTime _endDate = widget.event?.end.toLocal() ?? DateTime.now();
  late DateTime _startTime = widget.event?.start.toLocal() ?? DateTime.now();
  late DateTime _endTime = widget.event?.end.toLocal() ?? DateTime.now();
  late String? _amount = widget.event?.amount?.toString();
  late final List<CalendarEventParticipants> _participants =
      List.from(widget.event?.participants ?? []);

  @override
  void initState() {
    super.initState();
    _startDate = _startDate.stripTime();
    _endDate = _endDate.stripTime();
    _startTime = _startTime.stripDate();
    _endTime = _endTime.stripDate();
  }

  @override
  Widget build(BuildContext context) => ContentDialog(
        title: Text(widget.title),
        constraints: const BoxConstraints(maxWidth: 650),
        actions: [
          Button(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState!.save();

                final start = _startDate.mergeTime(_startTime);
                final end = _endDate.mergeTime(_endTime);

                late final CalendarEvents event;
                if (widget.event != null) {
                  event = widget.event!.copyWith(
                    start: start.toUtc,
                    end: end.toUtc,
                    title: () => _title!,
                    description: () => _description,
                    participants: () => _participants,
                    amount: () => _participants.isNotEmpty
                        ? Currency.fromString(_amount!).asInt
                        : null,
                  );
                } else {
                  event = CalendarEvents(
                    title: _title!,
                    start: start.toUtc(),
                    end: end.toUtc(),
                    description: _description,
                    type: _participants.isNotEmpty
                        ? CalendarEventsType.withParticipants
                        : CalendarEventsType.plain,
                    participants: _participants,
                    amount: _participants.isNotEmpty
                        ? Currency.fromString(_amount!).asInt
                        : null,
                  );
                }

                Navigator.of(context).pop(event);
              }
            },
            child: const Text('Save'),
          ),
          Button(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: TextFormBox(
                  placeholder: 'Title',
                  initialValue: _title,
                  onSaved: (value) => _title = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                children: [
                  FormField<DateTime>(
                    initialValue: _startDate,
                    onSaved: (value) => _startDate = value!,
                    validator: (value) {
                      if (value == null) return 'Start date is required';
                      if (value.isAfter(_endDate)) {
                        return 'Start date must be before end date';
                      }
                      return null;
                    },
                    builder: (formState) => Column(
                      children: [
                        DatePicker(
                          header: 'Start date',
                          selected: _startDate,
                          onChanged: (date) {
                            date = date.stripTime();
                            if (date.isAfter(_endDate)) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                            setState(() {
                              _startDate = date;
                            });
                          },
                        ),
                        if (formState.hasError)
                          Text(
                            formState.errorText ?? '',
                            style: FluentTheme.of(context)
                                .typography
                                .caption!
                                .copyWith(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FormField<DateTime>(
                    initialValue: _startTime,
                    onSaved: (value) => _startTime = value!,
                    validator: (value) {
                      if (value == null) return 'Start time is required';
                      if (value.isAfter(_endTime)) {
                        return 'Start time must be before end time';
                      }
                      return null;
                    },
                    builder: (formState) => Column(
                      children: [
                        TimePicker(
                          header: 'Start time',
                          selected: _startTime,
                          minuteIncrement: 5,
                          hourFormat: HourFormat.HH,
                          onChanged: (time) {
                            time = time.stripDate();
                            if (time.isAfter(_endTime)) {
                              setState(() {
                                _endTime = time;
                              });
                            }
                            setState(() {
                              _startTime = time;
                            });
                          },
                        ),
                        if (formState.hasError)
                          Text(
                            formState.errorText ?? '',
                            style: FluentTheme.of(context)
                                .typography
                                .caption!
                                .copyWith(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  FormField<DateTime>(
                    initialValue: _endDate,
                    onSaved: (value) => _endDate = value!,
                    validator: (value) {
                      if (value == null) return 'End date is required';
                      if (value.isBefore(_startDate)) {
                        return 'End date must be after start date';
                      }
                      return null;
                    },
                    builder: (formState) => Column(
                      children: [
                        DatePicker(
                          header: 'End date',
                          selected: _endDate,
                          onChanged: (date) {
                            date = date.stripTime();
                            if (date.isBefore(_startDate)) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                            setState(() {
                              _endDate = date;
                            });
                          },
                        ),
                        if (formState.hasError)
                          Text(
                            formState.errorText ?? '',
                            style: FluentTheme.of(context)
                                .typography
                                .caption!
                                .copyWith(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FormField<DateTime>(
                    initialValue: _endTime,
                    onSaved: (value) => _endTime = value!,
                    validator: (value) {
                      if (value == null) return 'End time is required';
                      if (value.isBefore(_startTime)) {
                        return 'End time must be after start time';
                      }
                      return null;
                    },
                    builder: (formState) => Column(
                      children: [
                        TimePicker(
                          header: 'End time',
                          selected: _endTime,
                          minuteIncrement: 5,
                          hourFormat: HourFormat.HH,
                          onChanged: (time) {
                            time = time.stripDate();
                            if (time.isBefore(_startTime)) {
                              setState(() {
                                _startTime = time;
                              });
                            }
                            setState(() {
                              _endTime = time;
                            });
                          },
                        ),
                        if (formState.hasError)
                          Text(
                            formState.errorText ?? '',
                            style: FluentTheme.of(context)
                                .typography
                                .caption!
                                .copyWith(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: TextFormBox(
                  placeholder: 'Description',
                  onSaved: (value) => value?.isEmpty ?? true
                      ? _description = null
                      : _description = value,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: CustomerAutoSuggest(
                  filteredCustomers: _participants
                      .map((e) => e.customer)
                      .whereType<Customers>()
                      .toList(),
                  onSelected: (customer) {
                    setState(() {
                      _participants.add(
                        CalendarEventParticipants(
                          customer: customer,
                          status: CalendarEventParticipantsStatus.pending,
                        ),
                      );
                    });
                  },
                ),
              ),
              for (final participant in _participants)
                ListTile(
                  title: Text(participant.customer?.name ?? 'Unknown'),
                  trailing: ComboBox<CalendarEventParticipantsStatus>(
                    value: participant.status,
                    items: CalendarEventParticipantsStatus.values
                        .map(
                          (e) => ComboBoxItem(
                            value: e,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      assert(value != null, 'Value cannot be null');
                      final index = _participants.indexOf(participant);
                      setState(() {
                        _participants[index] =
                            participant.copyWith(status: () => value!);
                      });
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: TextFormBox(
                  initialValue: _amount,
                  placeholder: 'Price',
                  onSaved: (value) => _amount = value,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (_participants.isEmpty) return null;
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

class CustomerAutoSuggest extends StatefulWidget {
  final List<Customers> filteredCustomers;
  final void Function(Customers)? onSelected;

  const CustomerAutoSuggest({
    super.key,
    this.onSelected,
    this.filteredCustomers = const [],
  });

  @override
  State<CustomerAutoSuggest> createState() => _CustomerAutoSuggestState();
}

class _CustomerAutoSuggestState extends State<CustomerAutoSuggest> {
  final List<Customers> _customers = [];
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _loadCustomers(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 50), () {
      final appwrite = getIt<AppwriteClient>();

      unawaited(
        appwrite.databases.listDocuments(
          databaseId: Customers.collectionInfo.databaseId,
          collectionId: Customers.collectionInfo.$id,
          queries: [
            Query.search('name', query),
          ],
        ).then((result) {
          final items = result.documents.map(Customers.fromAppwrite);
          final newItems = items.where(
            (element) =>
                !widget.filteredCustomers.any((e) => e.$id == element.$id) &&
                !_customers.any((e) => e.$id == element.$id),
          );

          setState(() {
            _customers.addAll(newItems);
          });
        }),
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AutoSuggestBox<Customers>(
        controller: _controller,
        placeholder: 'Search for customers',
        textInputAction: TextInputAction.search,
        onSelected: (item) {
          setState(() {
            widget.filteredCustomers.add(item.value!);
            _customers.remove(item.value);
          });
          widget.onSelected?.call(item.value!);
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _controller.clear();
          });
        },
        onChanged: (text, reason) {
          if (reason == TextChangedReason.userInput) {
            _loadCustomers(text);
          }
        },
        items: _customers
            .map(
              (e) => AutoSuggestBoxItem(
                label: e.name,
                value: e,
              ),
            )
            .toList(),
      );
}

Future<void> displayNewEventDialog(BuildContext context) async {
  await showDialog<CalendarEvents>(
    context: context,
    builder: (context) => const EventInputDialog(
      title: 'New Event',
    ),
  ).then((value) async {
    if (value != null) {
      // save event
      final appwrite = getIt<AppwriteClient>();

      try {
        // TODO: refactor to use relationLevels
        final data = value.toAppwrite();
        data['participants'] = value.participants?.map((e) {
              final item = e.toAppwrite(relationLevels: [true]);
              item['customer'] = e.customer?.$id;
              return item;
            }).toList() ??
            [];

        await appwrite.databases.createDocument(
          databaseId: CalendarEvents.collectionInfo.databaseId,
          collectionId: CalendarEvents.collectionInfo.$id,
          documentId: value.$id,
          data: data,
        );
      } on AppwriteException catch (e) {
        if (!context.mounted) return;
        await showResultInfo(
          context,
          Failure(e.message ?? 'Failed to create event'),
        );
      }
    }
  });
}

Future<void> displayEditEventDialog(
  BuildContext context,
  CalendarEvents event,
) async {
  await showDialog<CalendarEvents>(
    context: context,
    builder: (context) => EventInputDialog(
      title: 'Edit Event',
      event: event,
    ),
  ).then((value) {
    if (value != null) {
      // save event
      value.update().then(
            (response) =>
                context.mounted ? showResultInfo(context, response) : null,
          );
    }
  });
}
