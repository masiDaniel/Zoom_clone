import 'package:flutter/material.dart';
import 'package:zoom_clone/resources/firestore_methods.dart';

class HitstoryMeetingScreen extends StatelessWidget {
  const HitstoryMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreMethods().meetingsHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No meetings found"));
        }

        final meetings = snapshot.data!.docs;

        return ListView.builder(
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            final meeting = meetings[index];

            return ListTile(
              title: Text("Room Name: ${meeting['meetingName']}"),
              subtitle: Text(
                "Joined on: ${meeting['createdAt'].toDate().toString()}",
              ),
              leading: const Icon(Icons.video_call),
            );
          },
        );
      },
    );
  }
}
