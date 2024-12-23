import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:http/http.dart' as http;
import 'package:system_tray/system_tray.dart';
import 'dart:convert';

import 'package:window_manager/window_manager.dart';

class MGRCallerPopup extends StatefulWidget {
  final String phoneNumber;
  final String mgrUuid;
  final VoidCallback? onClose;

  const MGRCallerPopup({
    Key? key,
    required this.phoneNumber,
    required this.mgrUuid,
    this.onClose,
  }) : super(key: key);

  @override
  _MGRCallerPopupState createState() => _MGRCallerPopupState();
}

class _MGRCallerPopupState extends State<MGRCallerPopup>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? contactInfo;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchMGRInformation();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  Future<void> _fetchMGRInformation() async {
    try {
      final String mgrUrl =
          'https://www.mygadgetrepairs.com/external/pbx-call.cfm'
          '?uuid=${widget.mgrUuid}'
          '&did=${widget.phoneNumber}'
          '&type=json';

      final response = await http.get(Uri.parse(mgrUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          contactInfo = data['contact'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No information found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error retrieving information';
        isLoading = false;
      });
    }
  }

  String _getActionButtonText() {
    if (contactInfo == null) return 'Create Customer';
    if (contactInfo!['ticket_id'] != null) return 'View Ticket';
    if (contactInfo!['lead_id'] != null) return 'View Lead';
    if (contactInfo!['id'] != null) return 'View Customer';
    return 'Create Customer';
  }

  Color _getStatusColor() {
    final status = contactInfo?['status']?.toString().toLowerCase() ?? '';
    if (status.contains('active')) return Colors.green;
    if (status.contains('pending')) return Colors.orange;
    if (status.contains('closed')) return Colors.grey;
    return Colors.blue;
  }

  void _handleActionButton() {
    if (contactInfo == null) {
      _createNewCustomer();
      return;
    }

    if (contactInfo!['ticket_id'] != null) {
      _navigateToTicket(contactInfo!['ticket_id'].toString());
    } else if (contactInfo!['lead_id'] != null) {
      _navigateToLead(contactInfo!['lead_id'].toString());
    } else if (contactInfo!['id'] != null) {
      _navigateToCustomer(contactInfo!['id'].toString());
    } else {
      _createNewCustomer();
    }
  }

  void _navigateToTicket(String ticketId) {
    print('Navigating to ticket: $ticketId');
    // Implement actual navigation
  }

  void _navigateToLead(String leadId) {
    print('Navigating to lead: $leadId');
    // Implement actual navigation
  }

  void _navigateToCustomer(String customerId) {
    print('Navigating to customer: $customerId');
    // Implement actual navigation
  }

  void _createNewCustomer() {
    print('Creating new customer');
    // Implement customer creation
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: fluent.Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: fluent.ProgressRing())
                else if (errorMessage != null)
                  _buildErrorState()
                else
                  _buildContent(),
                const SizedBox(height: 16),
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Incoming Call',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        fluent.IconButton(
          icon: const Icon(fluent.FluentIcons.chrome_close),
          onPressed: () {
            _animationController.reverse().then((_) {
              widget.onClose?.call();
            });
          },
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Name',
          contactInfo?['firstname'] ?? 'Unknown',
          fluent.FluentIcons.contact,
        ),
        _buildInfoRow(
          'Phone',
          widget.phoneNumber,
          fluent.FluentIcons.phone,
        ),
        if (contactInfo?['email'] != null)
          _buildInfoRow(
            'Email',
            contactInfo!['email'],
            fluent.FluentIcons.mail,
          ),
        if (contactInfo?['company'] != null)
          _buildInfoRow(
            'Company',
            contactInfo!['company'],
            fluent.FluentIcons.home,
          ),
        if (contactInfo?['status'] != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  fluent.FluentIcons.status_circle_sync,
                  size: 12,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  contactInfo!['status'],
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: fluent.FilledButton(
        onPressed: _handleActionButton,
        child: Text(_getActionButtonText()),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

const WindowOptions windowOptions = WindowOptions(
  size: Size(800, 600),
  // Adjusted size to match popup dimensions
  center: false,
  backgroundColor: Colors.transparent,
  skipTaskbar: true,
  titleBarStyle: TitleBarStyle.hidden,
  alwaysOnTop: true, // Make window always on top
);

Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.mica, // Apply Mica effect
    dark: false, // Use light theme
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setAlignment(Alignment.bottomRight);
    await windowManager.show();
/*    await windowManager.setPosition(const Offset(
        1920 - 350 - 16,  // Screen width - popup width - margin
        1080 - 400 - 16   // Screen height - popup height - margin
    ));*/
  });
}

Future<void> showPop() async {
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.show();
  });
}

Future<SystemTray> buildSystemTray() async {
  final SystemTray systemTray = SystemTray();
  await systemTray
      .initSystemTray(
    title: "MGR Caller",
    iconPath: 'assets/app_icon.ico',
  )
      .catchError(
    (err) {
      print('Error: $err');
      return false;
    },
  );

  // Build context menu for the systemtray
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: 'Show Test Popup',
      onClicked: (_) async {
        await showPop();
        print('Opening pop');
      },
    ),
    MenuItemLabel(
        label: 'Exit',
        onClicked: (_) => {
              windowManager.destroy(),
              print('user initited destruction of window'),
            }),
  ]);

  // Handle system tray events
  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName.contains(kSystemTrayEventRightClick)) {
      systemTray.popUpContextMenu(); // Show the content options from above if right click is pressed on its icon in the tray
    }
  });
  await systemTray.setContextMenu(menu);
  return systemTray;
}

// Example usage
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWindow();
  buildSystemTray();
  print('Await done');

  runApp(
    fluent.FluentApp(
      theme: fluent.FluentThemeData(
        brightness: Brightness.light,
        accentColor: fluent.Colors.blue,
      ),
      home: const TransparentWindow(),
    ),
  );
}

class TransparentWindow extends StatelessWidget {
  const TransparentWindow({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure the window is transparent
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          MGRCallerPopup(
            phoneNumber: '07912345678',
            mgrUuid: 'your-mgr-uuid',
            onClose: () async {
              await windowManager.hide();
              print('Pressed X');
            },
          ),
        ],
      ),
    );
  }

// Update the build method in _MGRCallerPopupState
}
