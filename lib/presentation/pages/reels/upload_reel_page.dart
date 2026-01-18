import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import '../../../providers/reels_provider.dart';
import '../../../providers/my_auctions_provider.dart';
import '../../../data/models/auction_model.dart';

/// Upload Reel Page
class UploadReelPage extends StatefulWidget {
  final String? preSelectedAuctionId;

  const UploadReelPage({
    super.key,
    this.preSelectedAuctionId,
  });

  @override
  State<UploadReelPage> createState() => _UploadReelPageState();
}

class _UploadReelPageState extends State<UploadReelPage> {
  File? _videoFile;
  VideoPlayerController? _videoController;
  final TextEditingController _captionController = TextEditingController();
  String? _selectedAuctionId;
  AuctionModel? _selectedAuction;
  bool _isPickingVideo = false;
  bool _isCompressing = false;
  double _compressionProgress = 0;
  Duration _videoDuration = Duration.zero;
  static const int _maxDurationSeconds = 60;

  @override
  void initState() {
    super.initState();
    _selectedAuctionId = widget.preSelectedAuctionId;
    
    // Load user's auctions for selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyAuctionsProvider>().refreshMyAuctions();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    VideoCompress.cancelCompression();
    super.dispose();
  }

  Future<File?> _compressVideo(File videoFile) async {
    setState(() {
      _isCompressing = true;
      _compressionProgress = 0;
    });

    // Listen to compression progress
    VideoCompress.compressProgress$.subscribe((progress) {
      if (mounted) {
        setState(() => _compressionProgress = progress);
      }
    });

    try {
      final MediaInfo? info = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.Res1920x1080Quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info != null && info.file != null) {
        return info.file!;
      }
      return videoFile; // Return original if compression fails
    } catch (e) {
      debugPrint('Compression error: $e');
      return videoFile; // Return original if compression fails
    } finally {
      if (mounted) {
        setState(() => _isCompressing = false);
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    if (_isPickingVideo || _isCompressing) return;
    
    setState(() => _isPickingVideo = true);

    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: _maxDurationSeconds),
      );

      if (video != null) {
        File file = File(video.path);
        
        // Initialize video controller to check duration and resolution
        final tempController = VideoPlayerController.file(file);
        await tempController.initialize();
        
        final duration = tempController.value.duration;
        final videoWidth = tempController.value.size.width;
        final videoHeight = tempController.value.size.height;
        
        tempController.dispose();
        
        if (duration.inSeconds > _maxDurationSeconds) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('مدة الفيديو يجب أن تكون أقل من 60 ثانية'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Compress video if resolution is higher than 1080p
        if (videoWidth > 1920 || videoHeight > 1080) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('جاري ضغط الفيديو إلى 1080p...'),
                backgroundColor: Colors.blue,
              ),
            );
          }
          final compressedFile = await _compressVideo(file);
          if (compressedFile != null) {
            file = compressedFile;
          }
        }

        // Dispose old controller
        _videoController?.dispose();

        // Initialize new controller with (possibly compressed) file
        final controller = VideoPlayerController.file(file);
        await controller.initialize();

        setState(() {
          _videoFile = file;
          _videoController = controller;
          _videoDuration = duration;
        });

        controller.setLooping(true);
        controller.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الفيديو: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingVideo = false);
      }
    }
  }

  void _showVideoSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر مصدر الفيديو',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.videocam, color: Colors.purple),
                ),
                title: const Text('تصوير فيديو'),
                subtitle: const Text('سجل فيديو جديد'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: const Text('اختيار من المعرض'),
                subtitle: const Text('اختر فيديو موجود'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuctionSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<MyAuctionsProvider>(
            builder: (context, myAuctionsProvider, child) {
              final auctions = myAuctionsProvider.myAuctions;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'اختر المزاد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: auctions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.gavel_outlined,
                                    size: 60, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'ليس لديك مزادات',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'قم بإضافة مزاد أولاً',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: auctions.length,
                            itemBuilder: (context, index) {
                              final auction = auctions[index];
                              final isSelected = _selectedAuctionId == auction.id;

                              return Card(
                                elevation: isSelected ? 4 : 1,
                                color: isSelected
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1)
                                    : null,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isSelected
                                      ? BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        )
                                      : BorderSide.none,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: auction.images.isNotEmpty
                                        ? Image.network(
                                            auction.images.first,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image),
                                          ),
                                  ),
                                  title: Text(
                                    auction.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${auction.currentPrice} د.ع',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedAuctionId = auction.id;
                                      _selectedAuction = auction;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _uploadReel() async {
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار فيديو')),
      );
      return;
    }

    if (_selectedAuctionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المزاد')),
      );
      return;
    }

    final reelsProvider = context.read<ReelsProvider>();

    try {
      await reelsProvider.uploadReel(
        videoFile: _videoFile!,
        auctionId: _selectedAuctionId!,
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الريل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفع الريل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع ريل'),
        actions: [
          Consumer<ReelsProvider>(
            builder: (context, provider, child) {
              if (provider.isUploading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: provider.uploadProgress,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }

              return TextButton(
                onPressed: _uploadReel,
                child: const Text(
                  'نشر',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video preview / picker
            GestureDetector(
              onTap: _isCompressing ? null : _showVideoSourceDialog,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _isCompressing
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _compressionProgress / 100,
                              strokeWidth: 4,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'جاري ضغط الفيديو... ${_compressionProgress.toInt()}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'يتم ضغط الفيديو إلى 1080p',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _videoFile != null && _videoController != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _videoController!.value.isInitialized
                                ? AspectRatio(
                                    aspectRatio:
                                        _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator()),
                          ),
                          
                          // Play/Pause overlay
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                                setState(() {});
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: AnimatedOpacity(
                                    opacity: _videoController!.value.isPlaying
                                        ? 0
                                        : 1,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Duration badge
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_videoDuration.inSeconds}s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          
                          // Change video button
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _showVideoSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_call_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'اضغط لاختيار فيديو',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'الحد الأقصى 60 ثانية',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Caption input
            TextField(
              controller: _captionController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'الوصف (اختياري)',
                hintText: 'اكتب وصفاً للريل...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Auction selector
            const Text(
              'المزاد المرتبط *',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showAuctionSelector,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedAuction != null
                    ? Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _selectedAuction!.images.isNotEmpty
                                ? Image.network(
                                    _selectedAuction!.images.first,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedAuction!.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_selectedAuction!.currentPrice} د.ع',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.gavel_outlined),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'اختر المزاد المرتبط',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يجب ربط كل ريل بمزاد لعرض المنتج للمشاهدين',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 32),

            // Upload progress
            Consumer<ReelsProvider>(
              builder: (context, provider, child) {
                if (!provider.isUploading) return const SizedBox.shrink();

                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: provider.uploadProgress,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'جاري الرفع... ${(provider.uploadProgress * 100).toInt()}%',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Upload Button
            Consumer<ReelsProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.isUploading ? null : _uploadReel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: provider.isUploading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'جاري الرفع ${(provider.uploadProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'نشر الريل',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
