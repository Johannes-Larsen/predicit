import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/market_repository.dart';
import '../data/permission_service.dart';
import '../models/market.dart';
import '../providers/location_model.dart';
import '../utils/formatters.dart';

class CreateMarketScreen extends StatefulWidget {
  const CreateMarketScreen({super.key});

  @override
  State<CreateMarketScreen> createState() => _CreateMarketScreenState();
}

class _CreateMarketScreenState extends State<CreateMarketScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController =
      TextEditingController(text: 'Student');
  int _yesPriceCents = 50;
  String? _photoPath;
  String? _photoStatus;
  Position? _position;
  String? _locationStatus;
  bool _busy = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _choosePhotoSource() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    await _pickPhoto(source);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    setState(() {
      _busy = true;
      _photoStatus = null;
    });

    final PermissionService permissions = context.read<PermissionService>();
    final PermissionOutcome outcome = source == ImageSource.camera
        ? await permissions.requestCamera()
        : await permissions.requestPhotos();

    if (outcome != PermissionOutcome.granted) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _photoStatus = outcome == PermissionOutcome.permanentlyDenied
            ? 'Photo access is blocked in Settings. Open Settings to allow it.'
            : 'Photo access was denied this time. You can try again.';
      });
      return;
    }

    try {
      final XFile? file = await ImagePicker().pickImage(source: source);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _photoPath = file?.path;
        _photoStatus = file == null ? 'Canceled. No photo.' : 'Photo selected.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _photoStatus = 'Could not get a photo: $e';
      });
    }
  }

  Future<void> _captureLocation() async {
    setState(() {
      _busy = true;
      _locationStatus = null;
    });

    final LocationModel locationModel = context.read<LocationModel>();
    await locationModel.refresh();
    if (!mounted) return;

    setState(() {
      _busy = false;
      _position = locationModel.position;
      _locationStatus = _position == null
          ? (locationModel.message ?? "Couldn't get a location right now.")
          : 'Location captured.';
    });
  }

  void _submit() {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a market question first.')),
      );
      return;
    }

    final DateTime now = DateTime.now();
    // Created markets are intentionally local/in-memory for A8. Persistence of
    // user-created markets is not part of this assignment.
    final Market market = Market(
      id: 'created-${now.microsecondsSinceEpoch}',
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? 'Created from this device.'
          : _descriptionController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'Student'
          : _categoryController.text.trim(),
      yesPriceCents: _yesPriceCents,
      volumeShares: 0,
      closesAt: now.add(const Duration(days: 7)),
      imageAsset: 'assets/images/flutter.svg',
      photoPath: _photoPath,
      latitude: _position?.latitude,
      longitude: _position?.longitude,
      priceHistory: <PricePoint>[
        PricePoint(timestamp: now, yesPriceCents: _yesPriceCents),
      ],
    );

    MarketRepository().addCreatedMarket(market);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Market created.')),
    );
    context.pop(true);
  }

  bool get _settingsNeeded =>
      (_photoStatus?.contains('Settings') ?? false) ||
      (_locationStatus?.contains('Settings') ?? false);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create market')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Will it rain on campus tomorrow?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Add details people should know before betting.',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            Text('YES price: ${Formatters.price(_yesPriceCents)}'),
            Slider(
              min: 1,
              max: 99,
              divisions: 98,
              value: _yesPriceCents.toDouble(),
              label: Formatters.price(_yesPriceCents),
              onChanged: (double value) {
                setState(() => _yesPriceCents = value.round());
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _choosePhotoSource,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add photo'),
            ),
            if (_photoStatus != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(_photoStatus!),
            ],
            if (_photoPath != null) ...<Widget>[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_photoPath!),
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _captureLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Capture location'),
            ),
            if (_locationStatus != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(_locationStatus!),
            ],
            if (_position != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                'Lat ${_position!.latitude.toStringAsFixed(4)}, '
                'Lng ${_position!.longitude.toStringAsFixed(4)}',
                style: textTheme.bodySmall,
              ),
            ],
            if (_settingsNeeded) ...<Widget>[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: context.read<PermissionService>().openSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: const Text('Create market'),
            ),
          ],
        ),
      ),
    );
  }
}
