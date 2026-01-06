import 'package:flutter/material.dart';
import 'package:zoom_clone/resources/jitsi_meet_methods.dart';
import 'package:zoom_clone/widgets/home_meeting_buttons.dart';
import 'dart:math';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();
  createNewMeeting() async {
    var random = Random();
    String roomName = (1000000 + random.nextInt(9000000)).toString();
    _jitsiMeetMethods.createMeeting(roomName: roomName);
  }

  joinMeeting(BuildContext context) {
    Navigator.pushNamed(context, '/video-call');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HomeMeetingButtons(
              onPressed: createNewMeeting,
              text: "New Meeting",
              icon: Icons.videocam,
            ),
            HomeMeetingButtons(
              onPressed: () {
                joinMeeting(context);
              },
              text: "Join Meeting",
              icon: Icons.add_box_rounded,
            ),
            HomeMeetingButtons(
              onPressed: () {},
              text: "Schedule",
              icon: Icons.calendar_month,
            ),
            HomeMeetingButtons(
              onPressed: () {},
              text: "Share Screen",
              icon: Icons.arrow_upward,
            ),
          ],
        ),
        const Expanded(
          child: Center(
            child: Text(
              "Create/Join Meetings with just a click!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
