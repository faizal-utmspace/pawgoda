// lib/pages/activity_details_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/widgets/activity_card.dart';
import 'package:pawgoda/utils/styles.dart';

class ActivityDetailsPage extends StatefulWidget {
  // NOTE: bookingId is required because activities are subcollections under bookings/{bookingId}/activities
  final String bookingId;
  final String activityId;
  final Map<String, dynamic> activityData; // initial basic data for header

  const ActivityDetailsPage({
    Key? key,
    required this.bookingId,
    required this.activityId,
    required this.activityData,
  }) : super(key: key);

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedFile;
  bool _isVideo = false;
  bool _isImage = false;
  bool _isUploading = false;

  // Helper getter for the activity document reference
  DocumentReference<Map<String, dynamic>> get _activityDocRef =>
      FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .collection('activities')
          .doc(widget.activityId);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Pick an image (optional)
  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
        _isVideo = false;
        _isImage = true;
      });
    }
  }

  // Pick a video (optional)
  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
        _isVideo = true;
        _isImage = false;
      });
    }
  }

  // Check if all activities are completed and update booking status
  Future<void> _checkAndUpdateBookingStatus() async {
    try {
      debugPrint('🔍 Checking if all activities are completed...');
      
      // Get all activities for this booking
      final activitiesSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .collection('activities')
          .get();

      if (activitiesSnapshot.docs.isEmpty) {
        debugPrint('⚠️ No activities found for this booking');
        return;
      }

      // Check if all activities are completed
      bool allCompleted = true;
      int totalActivities = activitiesSnapshot.docs.length;
      int completedCount = 0;

      for (var doc in activitiesSnapshot.docs) {
        final status = doc.data()['status'];
        if (status == 'Completed') {
          completedCount++;
        } else {
          allCompleted = false;
        }
      }

      debugPrint('📊 Activity Status: $completedCount/$totalActivities completed');

      // If all activities are completed, update booking status
      if (allCompleted) {
        debugPrint('✅ All activities completed! Updating booking status...');
        
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .update({
          'status': 'Completed',
          'completedAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Booking status updated to Completed!');
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('🎉 All activities completed! Booking marked as complete.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('⏳ Still have pending activities: ${totalActivities - completedCount} remaining');
      }
    } catch (e) {
      debugPrint('❌ Error checking booking status: $e');
      // Don't show error to user as this is a background operation
    }
  }

  // Upload and post update: text required, media optional
  Future<void> _submitUpdate({bool isComplete = false}) async {
    final remarks = _textController.text.trim();

    if (remarks.isEmpty && !isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a message'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? mediaUrl;

      if (_selectedFile != null) {
        debugPrint('📤 Starting media upload...');
        debugPrint('   File: ${_selectedFile!.path}');
        debugPrint('   File exists: ${await _selectedFile!.exists()}');
        debugPrint('   File size: ${await _selectedFile!.length()} bytes');
        debugPrint('   IsVideo: $_isVideo, IsImage: $_isImage');
        
        try {
          // Check if storage is initialized
          final bucket = FirebaseStorage.instance.bucket;
          debugPrint('   Storage bucket: $bucket');
          
          if (bucket == null || bucket.isEmpty) {
            throw Exception('Storage bucket not configured. Please check Firebase setup.');
          }
          
          // Build a storage path
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final ext = _isVideo ? '.mp4' : '.jpg';
          final storagePath = 'activity_media/${widget.bookingId}/${widget.activityId}_$fileName$ext';
          
          debugPrint('   Storage path: $storagePath');
          
          // Try to use the explicit bucket URL
          final storageRef = FirebaseStorage.instanceFor(
            bucket: 'gs://pawgoda-app.firebasestorage.app',
          ).ref();
          
          final fileRef = storageRef.child(storagePath);
          
          debugPrint('   Storage bucket URL: gs://pawgoda-app.firebasestorage.app');
          debugPrint('   Full ref path: ${fileRef.fullPath}');

          // Upload file with metadata
          final metadata = SettableMetadata(
            contentType: _isVideo ? 'video/mp4' : 'image/jpeg',
            customMetadata: {
              'bookingId': widget.bookingId,
              'activityId': widget.activityId,
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          );
          
          debugPrint('   Starting upload task...');
          final uploadTask = fileRef.putFile(_selectedFile!, metadata);
          
          // Show upload progress
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            debugPrint('   Upload progress: ${progress.toStringAsFixed(1)}% (${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes)');
            debugPrint('   Upload state: ${snapshot.state}');
          });
          
          // Wait for upload to complete
          debugPrint('   Waiting for upload to complete...');
          final taskSnapshot = await uploadTask;
          
          debugPrint('   Upload task completed!');
          debugPrint('   Final state: ${taskSnapshot.state}');
          debugPrint('   Bytes transferred: ${taskSnapshot.bytesTransferred}');
          
          // Get download URL
          debugPrint('   Getting download URL...');
          mediaUrl = await fileRef.getDownloadURL();
          
          debugPrint('✅ Media uploaded successfully!');
          debugPrint('   Download URL: $mediaUrl');
        } catch (storageError, stackTrace) {
          debugPrint('❌ Storage upload failed!');
          debugPrint('   Error: $storageError');
          debugPrint('   Stack trace: $stackTrace');
          
          // Show user-friendly error dialog
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to upload media. Error: ${storageError.toString().substring(0, 50)}...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          
          // Continue without media if upload fails
          mediaUrl = null;
          setState(() {
            _selectedFile = null;
            _isVideo = false;
            _isImage = false;
            _isUploading = false;
          });
          
          // Return early - don't proceed with update
          return;
        }
      }



      if (remarks.isNotEmpty && isComplete == false) {
        // Prepare update object
        final updateObj = {
          'remarks': remarks,
          'mediaUrl': mediaUrl,
          'isVideo': _isVideo,
          'isImage': _isImage,
          'createdAt': DateTime.now()
        };

        debugPrint('💾 Updating activity with status: In Progress');
        
        // Push to the updates array
        await _activityDocRef.update({
          'updates': FieldValue.arrayUnion([updateObj]),
          'status': 'In Progress',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        debugPrint('✅ Marking activity as Completed');
        
        // If only marking complete without remarks
        await _activityDocRef.update({
          'status': 'Completed',
          'updates': FieldValue.arrayUnion([{
            'remarks': remarks.isEmpty ? 'Activity completed.' : remarks,
            'mediaUrl': mediaUrl,
            'isVideo': _isVideo,
            'isImage': _isImage,
            'createdAt': DateTime.now(),
          }]),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
   
      debugPrint('✅ Activity updated successfully!');
      
      // Check if all activities are completed and update booking status if needed
      if (isComplete) {
        await _checkAndUpdateBookingStatus();
      }
      
      // clear input & media
      _textController.clear();
      setState(() {
        _selectedFile = null;
        _isVideo = false;
        _isImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Activity updated successfully')
        ),
      );

      Navigator.pop(context);

    } catch (e, st) {
      debugPrint('❌ Activity update error: $e');
      debugPrint('   Stack trace: $st');
      
      String errorMessage = 'Error posting update';
      
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please check Firebase Storage rules.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('storage')) {
        errorMessage = 'Storage error. Failed to upload media.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // Open video player page when user taps play (initializes controller there)
  void _openVideoPlayer(String videoUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _VideoPlayerPage(videoUrl: videoUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
          ),
          child: Column(
            children: [
              // Close button row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Styles.blackColor),
                    ),
                  ),
                ],
              ),

              // Content
              Expanded(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _activityDocRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator(color: Styles.highlightColor));
                    }

                    final data = snapshot.data!.data() ?? {};
                    final updates = (data['updates'] as List<dynamic>?) ?? [];

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      children: [
                        // Activity header (use provided initial data for quick display)
                        ActivityCard(activity: widget.activityData),
                        const Gap(16),
                        Row(
                          children: [
                            Icon(Icons.update, color: Styles.highlightColor, size: 20),
                            const Gap(8),
                            Text('Updates Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Styles.blackColor)),
                          ],
                        ),
                        const Gap(12),

                        // If no updates
                        if (updates.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
                                const Gap(12),
                                Text('No updates yet', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                const Gap(4),
                                Text('Be the first to add an update!', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                              ],
                            ),
                          )
                        else
                          // Use ListView.builder-like column for updates (reversed timeline)
                          Column(
                            children: List.generate(updates.length, (index) {
                              final revIndex = updates.length - 1 - index;
                              final updateRaw = updates[revIndex];
                              final update = (updateRaw as Map<String, dynamic>?) ?? {};
                              final Timestamp? ts = update['createdAt'] as Timestamp?;
                              final dateStr = ts != null
                                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(ts.toDate())
                                  : 'Just now';

                              final text = update['remarks'] as String? ?? '';
                              final mediaUrl = update['mediaUrl'] as String?;
                              final isVideo = update['isVideo'] as bool? ?? false;

                              return _UpdateItem(
                                dateStr: dateStr,
                                text: text,
                                mediaUrl: mediaUrl,
                                isVideo: isVideo,
                                onPlayVideo: mediaUrl != null && isVideo ? () => _openVideoPlayer(mediaUrl) : null,
                              );
                            }),
                          ),

                        const Gap(18),
                        const Divider(),
                        const Gap(8),

                        // Upload section (text required, media optional)
                        if (_selectedFile != null)
                          Container(
                            height: 150,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[100],
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _isVideo
                                        ? Center(child: Icon(Icons.videocam, size: 48, color: Colors.grey[700]))
                                        : Image.file(_selectedFile!, fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: _isUploading
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedFile = null;
                                              _isVideo = false;
                                              _isImage = false;
                                            });
                                          },
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        widget.activityData['status'] != 'Completed' && widget.activityData['status'] != 'Incoming' ?
                        Column(
                            children: [
                              TextField(
                                controller: _textController,
                                maxLines: 3,
                                style: TextStyle(fontSize: 14, color: Styles.blackColor),
                                decoration: InputDecoration(
                                  hintText: 'Write an update...',
                                  hintStyle: TextStyle(color: Styles.blackColor.withOpacity(0.4)),
                                  filled: true,
                                  fillColor: Styles.bgWithOpacityColor,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Styles.highlightColor, width: 2)),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),

                              Row(
                                children: [
                                  const Gap(12),
                                  InkWell(
                                    onTap: _isUploading ? null : _pickImage,
                                    child: Icon(Icons.image_outlined, size: 28, color: Styles.highlightColor),
                                  ),
                                  const Gap(12),
                                  InkWell(
                                    onTap: _isUploading ? null : _pickVideo,
                                    child: Icon(Icons.videocam_outlined, size: 36, color: Styles.highlightColor),
                                  ),
                                ],
                              ),
                              const Gap(12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isUploading ? null : _submitUpdate,
                                      child: _isUploading
                                          ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Text('Post Update'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Styles.highlightColor.withOpacity(0.7),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isUploading ? null : () => _submitUpdate(isComplete: true),
                                      child: _isUploading
                                          ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Text('Complete Activity'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : widget.activityData['status'] == 'Incoming' 
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule, color: Colors.purple, size: 24),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Upcoming Activity',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        'This activity is scheduled for ${widget.activityData['scheduledDate']}. You can update it when the date arrives.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Styles.blackColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                        const Gap(24)
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Small widget for a single update item (stateless, lightweight)
class _UpdateItem extends StatelessWidget {
  final String dateStr;
  final String text;
  final String? mediaUrl;
  final bool isVideo;
  final VoidCallback? onPlayVideo;

  const _UpdateItem({
    Key? key,
    required this.dateStr,
    required this.text,
    required this.mediaUrl,
    required this.isVideo,
    required this.onPlayVideo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.access_time, size: 14, color: Styles.blackColor.withOpacity(0.5)),
          const Gap(6),
          Text(dateStr, style: TextStyle(fontSize: 12, color: Styles.blackColor.withOpacity(0.5))),
        ]),
        if (text.isNotEmpty) ...[
          const Gap(12),
          Text(text, style: TextStyle(fontSize: 14, color: Styles.blackColor, height: 1.5)),
        ],
        if (mediaUrl != null) ...[
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isVideo
                ? GestureDetector(
                    onTap: onPlayVideo,
                    child: Container(
                      height: 200,
                      color: Colors.black,
                      child: const Center(child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white)),
                    ),
                  )
                : Image.network(mediaUrl!, fit: BoxFit.cover, width: double.infinity),
          ),
        ],
      ]),
    );
  }
}

// Fullscreen video player page (initializes controller when opened)
class _VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _loading = false);
          _controller!.play();
        }
      }).catchError((e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video load error: $e')));
        }
      });
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)),
      ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                });
              },
              child: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
    );
  }
}