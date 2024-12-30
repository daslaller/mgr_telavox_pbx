// mgr_caller_controller.dart
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:http/http.dart' as http;
import 'dart:convert';

String mgrPbxUrl = "";

class MGRCallerController {
  final GlobalKey<MGRCallerPopupState> popupKey =
      GlobalKey<MGRCallerPopupState>();
  String _phoneNumber;
  String _mgrUuid;
  VoidCallback? _onClose;
  VoidCallback? _onShow;

  MGRCallerController({
    required String phoneNumber,
    required String mgrUuid,
    VoidCallback? onClose,
    VoidCallback? onShow,
  })  : _phoneNumber = phoneNumber,
        _mgrUuid = mgrUuid,
        _onClose = onClose,
        _onShow = onShow;

  // Update phone number and trigger rebuild
  void updatePhoneNumber(String newPhoneNumber) {
    _phoneNumber = newPhoneNumber;
    popupKey.currentState?.setState(() {/*_phoneNumber = newPhoneNumber;*/});
  }

  // Update MGR UUID and trigger rebuild
  void updateMgrUuid(String newUuid) {
    _mgrUuid = newUuid;
    popupKey.currentState?.setState(() {});
  }

  // Manually trigger animations
  void showPopup() {
    popupKey.currentState?.animationController.forward();
    _onShow?.call();
  }

  void hidePopup() {
    popupKey.currentState?.animationController.reverse();
    _onClose?.call();
  }

  // Refresh MGR information
  void refreshInfo() {
    popupKey.currentState?._fetchMGRInformation();
  }

  // Getters for current values
  String get phoneNumber => _phoneNumber;

  String get mgrUuid => _mgrUuid;
}

class MGRCallerPopup extends StatefulWidget {
  final MGRCallerController controller;

  const MGRCallerPopup({
    super.key,
    required this.controller,
  });

  @override
  MGRCallerPopupState createState() => MGRCallerPopupState();
}

class MGRCallerPopupState extends State<MGRCallerPopup>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? contactInfo;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchMGRInformation();
  }

  void _setupAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    animationController.forward();
  }

/*  https://www.mygadgetrepairs.com/external/pbx-call.cfm?uuid={uuid}&did=07912345678&type=json
    If you want the system to return any “Customer’s Custom Fields” data then you can send the custom field name in the “cf_name” parameter.
    https://www.mygadgetrepairs.com/external/pbx-call.cfm?uuid={uuid}&did=07912345678&type=json&cf_name=cf_70932*/

  Future<void> _fetchMGRInformation() async {
    try {
      final String mgrUrl =
          'https://www.mygadgetrepairs.com/external/pbx-call.cfm'
          '?uuid=${widget.controller.mgrUuid}'
          '&did=${widget.controller.phoneNumber}'
          '&type=json';
      mgrPbxUrl = mgrUrl; // Copy payload

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
    if (contactInfo!['ticket_id'] != null) {
      _navigateToTicket(contactInfo!['ticket_id'].toString());
    } else if (contactInfo!['lead_id'] != null) {
      _navigateToLead(contactInfo!['lead_id'].toString());
    } else if (contactInfo!['id'] != null) {
      _navigateToCustomer(contactInfo!['id'].toString());
    } else {
      _handleIncomingCall(); // probably the only thing needed really
      // https://www.mygadgetrepairs.com/external/pbx-call.cfm?uuid={your-uuid}&did={caller-did}&redirect=yes
      return;
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

  void _handleIncomingCall() {
    // follows mgr own implementation, which is to follow the pbx link with special
    // criteria
    print('Following MGR pbx link');
    if (mgrPbxUrl.isNotEmpty) {
      // code to go to this link
      print('Navigating to $mgrPbxUrl');
      return;
    }
    print('Expired!');
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
            animationController.reverse().then((_) {
              widget.controller._onClose?.call();
              print('exit was pressed on icon button');
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
          widget.controller.phoneNumber,
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
            fluent.FluentIcons.office_logo,
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

  // Main popup button
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: fluent.FilledButton(
        onPressed: _handleActionButton,
        child: Text(_getActionButtonText()),
      ),
    );
  }

  // Not sure if needed, might be an internal call to dispose, then the animation controller needs to be release, needs further understanding.
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class TransparentWindow extends StatefulWidget {
  final MGRCallerController controller;

  const TransparentWindow({
    super.key,
    required this.controller,
  });

  @override
  State<TransparentWindow> createState() => _TransparentWindowState();
}

class _TransparentWindowState extends State<TransparentWindow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          MGRCallerPopup(
            key: widget.controller.popupKey,
            controller: widget.controller,
          ),
        ],
      ),
    );
  }
}

fluent.FluentApp fluentApp(MGRCallerController controller) {
  return fluent.FluentApp(
    // Return a usuable dressed widget, the widget structure looks something like this: Top-> TransparentWindow (invisible big window, houses the important popup) -> Visiblepop with childs
    theme: fluent.FluentThemeData(
      brightness: Brightness.light,
      accentColor: fluent.Colors.blue,
    ),
    home: TransparentWindow(controller: controller),
  );
}
