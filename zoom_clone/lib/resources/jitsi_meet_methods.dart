import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:zoom_clone/resources/auth_methods.dart';
import 'package:zoom_clone/resources/firestore_methods.dart';

class JitsiMeetMethods {
  final JitsiMeet _jitsiMeetPlugin = JitsiMeet();
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  List<String> participants = [];

  /// Creates and joins a new Jitsi meeting as the creator/moderator
  Future<void> createMeeting({
    required String roomName,
    String username = '',
    bool audioMuted = true,
    bool videoMuted = true,
  }) async {
    String name;
    // Build Jitsi meeting options
    if (username.isEmpty) {
      name = _authMethods.user.displayName!;
    } else {
      name = username;
    }

    var options = JitsiMeetConferenceOptions(
      room: roomName,
      configOverrides: {
        "startWithAudioMuted": audioMuted,
        "startWithVideoMuted": videoMuted,
        "moderator": true, // Ensure the creator is the moderator
        "requireModerator": false, // Prevent waiting for someone else
      },
      featureFlags: {
        FeatureFlags.lobbyModeEnabled: false, // Skip lobby
        FeatureFlags.preJoinPageEnabled: false, // Skip pre-join screen
        FeatureFlags.welcomePageEnabled: false, // Skip welcome page
        FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution720p,
        FeatureFlags.audioMuteButtonEnabled: true,
        FeatureFlags.videoMuteEnabled: true,
        FeatureFlags.toolboxEnabled: true,
        FeatureFlags.chatEnabled: true,
        FeatureFlags.addPeopleEnabled: true,
        FeatureFlags.inviteEnabled: true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: name,
        email: _authMethods.user.email,
        avatar: _authMethods.user.photoURL,
      ),
    );

    // Jitsi event listener
    var listener = JitsiMeetEventListener(
      conferenceJoined: (url) => debugPrint("Joined meeting: $url"),
      conferenceTerminated: (url, error) =>
          debugPrint("Meeting ended: $url, error: $error"),
      participantJoined: (email, name, role, participantId) {
        debugPrint(
          "Participant joined: email=$email, name=$name, participantId=$participantId",
        );
        if (participantId != null) participants.add(participantId);
      },
      participantLeft: (participantId) {
        debugPrint("Participant left: $participantId");
        participants.remove(participantId);
      },
      audioMutedChanged: (muted) => debugPrint("Audio muted: $muted"),
      videoMutedChanged: (muted) => debugPrint("Video muted: $muted"),
      readyToClose: () => debugPrint("Meeting ready to close"),
    );

    _firestoreMethods.addToMeetingHistory(roomName);

    // Join the meeting immediately
    await _jitsiMeetPlugin.join(options, listener);
  }

  /// Hang up the meeting
  Future<void> hangUp() async {
    await _jitsiMeetPlugin.hangUp();
    participants.clear();
  }

  /// Toggle audio mute
  Future<void> setAudioMuted(bool muted) async {
    await _jitsiMeetPlugin.setAudioMuted(muted);
  }

  /// Toggle video mute
  Future<void> setVideoMuted(bool muted) async {
    await _jitsiMeetPlugin.setVideoMuted(muted);
  }

  /// Send message to all participants
  Future<void> sendEndpointTextMessage(String message) async {
    for (var p in participants) {
      await _jitsiMeetPlugin.sendEndpointTextMessage(to: p, message: message);
    }
  }

  /// Toggle screen share
  Future<void> toggleScreenShare(bool enabled) async {
    await _jitsiMeetPlugin.toggleScreenShare(enabled);
  }

  /// Open chat
  Future<void> openChat() async {
    await _jitsiMeetPlugin.openChat();
  }

  /// Send chat message
  Future<void> sendChatMessage(String message) async {
    await _jitsiMeetPlugin.sendChatMessage(message: message);
  }

  /// Close chat
  Future<void> closeChat() async {
    await _jitsiMeetPlugin.closeChat();
  }

  /// Retrieve participants info
  Future<void> retrieveParticipantsInfo() async {
    var info = await _jitsiMeetPlugin.retrieveParticipantsInfo();
    debugPrint("Participants info: $info");
  }
}
