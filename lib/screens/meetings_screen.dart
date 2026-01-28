import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  // Mock Data: List of Meetings
  List<Map<String, dynamic>> _meetings = [
    {
      'id': '1',
      'name': 'Ramesh K',
      'date': DateTime.now().add(const Duration(days: 0)), // Today
      'time': const TimeOfDay(hour: 16, minute: 0),
      'image': 'https://i.pravatar.cc/150?u=ramesh',
    },
    {
      'id': '2',
      'name': 'Anjali Verma',
      'date': DateTime.now().add(const Duration(days: 2)),
      'time': const TimeOfDay(hour: 14, minute: 30),
      'image': 'https://i.pravatar.cc/150?u=anjali',
    },
    {
      'id': '3',
      'name': 'Suresh Babu',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'time': const TimeOfDay(hour: 10, minute: 0),
      'image': 'https://i.pravatar.cc/150?u=suresh',
    },
  ];

  List<Map<String, dynamic>> _getMeetingsForDay(DateTime day) {
    return _meetings.where((meeting) {
      return isSameDay(meeting['date'] as DateTime, day);
    }).toList();
  }
  
  List<Map<String, dynamic>> _getMeetingsForMonth(DateTime day) {
    return _meetings.where((meeting) {
      return (meeting['date'] as DateTime).year == day.year &&
             (meeting['date'] as DateTime).month == day.month;
    }).toList();
  }

  void _showEditMeetingDialog(Map<String, dynamic> meeting) {
    TextEditingController nameController = TextEditingController(text: meeting['name']);
    TextEditingController dateController = TextEditingController(text: _dateFormat.format(meeting['date']));
    TextEditingController timeController = TextEditingController(text: _timeFormat.format(DateTime(2022,1,1, (meeting['time'] as TimeOfDay).hour, (meeting['time'] as TimeOfDay).minute)));
    
    DateTime selectedDate = meeting['date'];
    TimeOfDay selectedTime = meeting['time'];
    bool sendWhatsApp = true;
    bool notifyMe = true;
    String notifyValue = "30";
    String notifyUnit = "Minutes";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Center(child: Text('Edit Meeting', style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'Connection Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                         final DateTime? picked = await showDatePicker(
                           context: context,
                           initialDate: selectedDate,
                           firstDate: DateTime(2020),
                           lastDate: DateTime(2030),
                           builder: (context, child) {
                             return Theme(
                               data: Theme.of(context).copyWith(
                                 colorScheme: const ColorScheme.light(primary: Color(0xFFC61C2C)),
                               ),
                               child: child!,
                             );
                           },
                         );
                         if (picked != null) {
                           setStateDialog(() {
                             selectedDate = picked;
                             dateController.text = _dateFormat.format(picked);
                           });
                         }
                      },
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFC61C2C), size: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: timeController,
                      readOnly: true,
                       onTap: () async {
                         final TimeOfDay? picked = await showTimePicker(
                           context: context,
                           initialTime: selectedTime,
                           builder: (context, child) {
                             return Theme(
                               data: Theme.of(context).copyWith(
                                 colorScheme: const ColorScheme.light(primary: Color(0xFFC61C2C)),
                               ),
                               child: child!,
                             );
                           },
                         );
                         if (picked != null) {
                           setStateDialog(() {
                             selectedTime = picked;
                             final dt = DateTime(2022, 1, 1, picked.hour, picked.minute);
                             timeController.text = _timeFormat.format(dt);
                           });
                         }
                      },
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.access_time, color: Color(0xFFC61C2C), size: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Switch(
                          value: sendWhatsApp, 
                          activeColor: const Color(0xFF3F51B5),
                          onChanged: (val) => setStateDialog(() => sendWhatsApp = val)
                        ),
                        const Expanded(child: Text('Send updated time on WhatsApp', style: TextStyle(fontSize: 12))),
                      ],
                    ),
                    Row(
                      children: [
                         Switch(
                          value: notifyMe, 
                           activeColor: const Color(0xFF3F51B5),
                          onChanged: (val) => setStateDialog(() => notifyMe = val)
                        ),
                        const Text('Notify Me', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: TextEditingController(text: notifyValue),
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8), isDense: true),
                            onChanged: (val) => notifyValue = val,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                         const SizedBox(width: 8),
                         Expanded(
                           child: DropdownButtonHideUnderline(
                             child: DropdownButton<String>(
                               value: notifyUnit,
                               isExpanded: true,
                               isDense: true,
                               items: ['Minutes', 'Hours', 'Days', 'Weeks'].map((String value) {
                                 return DropdownMenuItem<String>(
                                   value: value,
                                   child: Text(value, style: const TextStyle(fontSize: 12)),
                                 );
                               }).toList(),
                               onChanged: (val) => setStateDialog(() => notifyUnit = val!),
                             ),
                           ),
                         ),
                      ],
                    )
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC61C2C)),
                    onPressed: () async {
                      // Update Logic
                      setState(() {
                         final index = _meetings.indexWhere((m) => m['id'] == meeting['id']);
                         if (index != -1) {
                           _meetings[index]['date'] = selectedDate;
                           _meetings[index]['time'] = selectedTime;
                         }
                      });
                      Navigator.pop(context);
                      
                      if (sendWhatsApp) {
                        final String message = "Hi ${meeting['name']},\nI have updated the meeting date/time to - ${_dateFormat.format(selectedDate)}, ${_timeFormat.format(DateTime(2022,1,1,selectedTime.hour, selectedTime.minute))}.\nHoping to talk to you soon.\nRegards,\nHemanth Sharma\nSpindigo Designs LLP\nwww.spindigo.design";
                        final Uri whatsappUrl = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
                        if (await canLaunchUrl(whatsappUrl)) {
                          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
                        }
                      }
                    }, 
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteMeetingDialog(Map<String, dynamic> meeting) {
    bool sendWhatsApp = true;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                     child: const Icon(Icons.delete, color: Color(0xFFC61C2C)),
                   ),
                   const SizedBox(height: 16),
                   const Text('Delete Meeting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                   const SizedBox(height: 8),
                   const Text(
                     'Are you sure? Deleting this meeting cannot be undone.',
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey, fontSize: 13),
                   ),
                   const SizedBox(height: 16),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                          value: sendWhatsApp, 
                          activeColor: const Color(0xFF3F51B5),
                          onChanged: (val) => setStateDialog(() => sendWhatsApp = val)
                        ),
                        const Text('Send update on WhatsApp', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                ],
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC61C2C)),
                  onPressed: () async {
                    setState(() {
                      _meetings.removeWhere((m) => m['id'] == meeting['id']);
                    });
                    Navigator.pop(context);

                    if (sendWhatsApp) {
                        final String message = "Hi ${meeting['name']},\nWe are scheduled to meet on ${_dateFormat.format(meeting['date'])}, ${_timeFormat.format(DateTime(2022,1,1,(meeting['time'] as TimeOfDay).hour, (meeting['time'] as TimeOfDay).minute))}.\nHoping to talk to you soon.\nRegards,\nHemanth Sharma\nSpindigo Designs\nwww.spindigo.design";
                         // Wait, delete implies cancellation usually? UI says "Send update on WhatsApp" with that template, 
                         // but context is 'Delete Meeting'. The template provided in prompt seems to be a reminder/confirmation template rather than cancellation?
                         // "We are scheduled to meet on..." sounds like confirmation. 
                         // User requested: "Once clicked, auto-trigger a WhatsApp message - To: ... Message: Hi Ramesh, We are scheduled to meet on..."
                         // This is weird for Delete logic. Maybe "We were scheduled..." or standard cancellation?
                         // User prompt explicitly says "We are scheduled to meet on...". I will follow prompt EXACTLY even if it sounds odd for delete.
                         // Maybe it implies "Hey just reminding you we HAD a meeting" no that's silly.
                         // Actually wait, looking at prompt text: "4. Delete Meeting... a. Send WhatsApp Message... Message: Hi Ramesh, We are scheduled to meet on..." 
                         // This text implies confirming the meeting exists? Or is it a copy-paste error in prompt?
                         // Ah, wait. The prompt says "Cancel" then "Delete (red button)".
                         // Let's assume the prompt text provided is what is desired.
                        final Uri whatsappUrl = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
                        if (await canLaunchUrl(whatsappUrl)) {
                          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                        }
                    }
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // Meetings to Display: Filtered by Current Month (focusedDay)
    final meetingsForList = _getMeetingsForMonth(_focusedDay);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meetings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC61C2C),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar View
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            currentDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getMeetingsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Color(0xFFC61C2C), // Red Circle for today
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: const Color(0xFFC61C2C).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                 color: Colors.transparent,
                 border: Border.all(color: const Color(0xFFC61C2C), width: 1),
                 shape: BoxShape.circle,
              ),
              // We need custom markers to match the "red circle with number" ideally, 
              // but TableCalendar's default markers are dots. 
              // To achieve exact UI "Dates that have at least one scheduled meeting show a red circle with the number" requires custom builder.
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC61C2C)),
                        color: Colors.white
                      ),
                      width: 24,
                      height: 24,
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(color: Color(0xFFC61C2C), fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
               // Customize Today to match UI (Solid Red Circle)
               todayBuilder: (context, date, _) {
                 return Center(
                   child: Container(
                     decoration: const BoxDecoration(color: Color(0xFFC61C2C), shape: BoxShape.circle),
                     width: 32,
                     height: 32,
                     child: Center(child: Text('${date.day}', style: const TextStyle(color: Colors.white))),
                   ),
                 );
               },
               // Customize Default to hide original text if marker is overlapping?
               // Actually using markerBuilder Positioned might overlay.
               // Let's rely on standard builders for simplicity unless strictly needed.
               // The prompt image shows the date text INSIDE the red circle outline.
               // So we should replace the `defaultBuilder` for days with events.
               defaultBuilder: (context, date, _) {
                  if (_getMeetingsForDay(date).isNotEmpty) {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFC61C2C)),
                          ),
                          width: 32,
                          height: 32,
                          child: Center(child: Text('${date.day}', style: const TextStyle(color: Color(0xFFC61C2C)))),
                        ),
                      );
                  }
                  return null;
               },
            ),
            headerStyle: const HeaderStyle(
              titleCentered: false,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ),
          
          Divider(thickness: 1, color: Colors.grey[200]),

          // Meetings List
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(
                    'Meetings for ${DateFormat('MMM yyyy').format(_focusedDay)}',
                    style: const TextStyle(
                      color: Color(0xFF3F51B5),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: meetingsForList.length,
                    separatorBuilder: (ctx, index) => Divider(color: Colors.grey[200], thickness: 1),
                    itemBuilder: (context, index) {
                      final meeting = meetingsForList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(meeting['image']),
                          backgroundColor: Colors.grey[200],
                        ),
                        title: Text(
                          meeting['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Date: ${_dateFormat.format(meeting['date'])}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            Text('Time: ${_timeFormat.format(DateTime(2022, 1, 1, (meeting['time'] as TimeOfDay).hour, (meeting['time'] as TimeOfDay).minute))}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz, color: Colors.grey),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showEditMeetingDialog(meeting);
                            } else if (val == 'delete') {
                              _showDeleteMeetingDialog(meeting);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  const Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  const Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
