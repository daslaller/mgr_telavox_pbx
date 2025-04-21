// mgr_caller_controller.dart


import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mgr_telavox_pbx/services/mygadgetrepairs/mygadgetrepairs.dart';
import 'dart:convert';

/*Need to create a short description window, and to the left of
 that window should be a picture of the device manufacturer. For say, its a Samsung S6,
 then the image should be grabbed from the resource folder for a
  galaxy s6 if not found an online resource should be used*/

/*class MGRCallerController {
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
    //  popupKey.currentState?.setState(() {
    //    _phoneNumber = newPhoneNumber;
    //  });
    // Doesnt work as intended and doesnt seem to do anything, even though my interpretation is similair to that of the platform call in javaFX. It indeed doesnt work in that manner.
  }

  // Update MGR UUID and trigger rebuild
  void updateMgrUuid(String newUuid) {
    _mgrUuid = newUuid;
    //popupKey.currentState?.setState(() {
    //  _mgrUuid = newUuid;
    //});
    // Doesnt work as intended and doesnt seem to do anything, even though my interpretation is similair to that of the platform call in javaFX. It indeed doesnt work in that manner.
  }

  // Getters for current values
  String get phoneNumber => _phoneNumber;

  String get mgrUuid => _mgrUuid;

  VoidCallback? get onShow => _onShow;

  set onShow(VoidCallback? value) {
    _onShow = value;
  }

  VoidCallback? get onClose => _onClose;

  set onClose(VoidCallback? value) {
    _onClose = value;
  }
}*/

class MGRCallerPopup extends StatefulWidget {
  // final MGRCallerController controller;
  final VoidCallback? onClose;
  final VoidCallback? onShow;
  final dynamic mgrUuid;
  final dynamic phoneNumber;

  //final Size size;

  const MGRCallerPopup({
    super.key,
    // required this.controller,
    this.onClose,
    this.onShow,
    this.mgrUuid,
    this.phoneNumber,
    // required this.size,
  });

  @override
  MGRCallerPopupState createState() => MGRCallerPopupState();
}

class MGRCallerPopupState extends State<MGRCallerPopup>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? contactInfo;
  bool isLoading = true;
  String? errorMessage;
  MgrUrl mgrUrl = MgrUrl();
  late Map rawData = {};
  late AnimationController animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
   // _buildSystemTray();
    _setupAnimations();
    _fetchMGRInformation();
    super.initState();
  }

  // Manually trigger animations
  void showPopup() {
    setState(() {
      animationController.forward().then((value) async {
        widget.onShow?.call();
        print('successful pop');
      });
    });
  }

  void hidePopup() {
    setState(() {
      animationController.reverse().then((value) async {
        widget.onClose?.call();
        print('Successful hide');
      });
    });
  }

  // Refresh MGR information
  void refreshInfo() {
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

  Future<void> _fetchMGRInformation({returnData, uuid, phonenumber}) async {
    if ((returnData ?? true) || (uuid ?? true) || (phonenumber ?? true)) {
      print('cant retrieve mgr data without UUID and Phonenumber.');
      isLoading = false;
      return;
    }
    try {
      isLoading = true;
      print('got mission to fetch');
      final response = await http.get(
          Uri.parse(mgrUrl.fetchMgrURL(uuid: uuid, phonenumber: phonenumber)));
      print('last url: ${mgrUrl.lastURL}');
      if (response.statusCode == 200) {
        returnData['rawdata'] = json.decode(response.body);
        setState(() {
          returnData['contact'] = rawData['contact'];
        });
      } else {
        setState(() {
          returnData['error'] = 'No information found, Responsecode != 200';
        });
      }
    } catch (e) {
      setState(() {
        returnData['error'] = 'Error retrieving information';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getActionButtonText() {
    if (contactInfo == null) return 'Hantera kund';
    // Should follow the redirect link:
    // https://www.mygadgetrepairs.com/external/pbx-call.cfm?uuid={your-uuid}&did={caller-did}&redirect=yes

    if (contactInfo!['ticket_id'] != null) return 'View Ticket';
    if (contactInfo!['lead_id'] != null) return 'View Lead';
    if (contactInfo!['id'] != null) return 'View Customer';
    return 'Create Customer';
  }

  // These should color the ticket and lead button depending on the information found from webhook,
  // if no information was found, the button shouldnt even exist.
  Color _getStatusColor() {
    final status = contactInfo?['status']?.toString().toLowerCase() ?? '';
    if (status.contains('active')) return Colors.green;
    if (status.contains('pending')) return Colors.orange;
    if (status.contains('closed')) return Colors.grey;
    return Colors.blue;
  }

// Everything should be displayed at once. So if we find a ticket id,
// display that and some information gathered and a button to visit that
// ticket, if a lead is found do the same and so on.
// In the end it should be like a profile card of what is found and a button to each option their
// is. Example:
// Picture of the device if found - (Some information about the customer, recent tickets, leads etc.)
  // button - Visit most recent ticket/active ticket, should be colored depending on status
  // Button - Visit most recent lead, should be colored depending on status
  // Button - Redirect button, is always shown in mica color.

  void _handleActionButton() {
    // ugly way of testing update function
    if (contactInfo!['ticket_id'] != null) {
      // Should be changed to show essential ticket info and an option to go to that ticket
      _navigateToTicket(contactInfo!['ticket_id'].toString());
    } else if (contactInfo!['lead_id'] != null) {
      // Should be changed to show what lead info there is and an option to go to that lead
      _navigateToLead(contactInfo!['lead_id'].toString());
    } else if (contactInfo!['id'] != null) {
      // Unsure whats claude meant by ID.... need further exploration.
      _navigateToCustomer(contactInfo!['id'].toString());
    } else {
      // This button is the only button thats always visible even if a nothing was found about the customer.
      _redirectToFetchURL(); // probably the only thing needed really
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

  void _redirectToFetchURL() {
    // follows mgr own implementation, which is to follow the pbx link with special
    // criteria
    print('Following MGR pbx link');
    print('Expired!');
    // Implement customer creation
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Mica(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(8),
          width: 350,
          height: 200,
/*          child: fluent.Card(
            backgroundColor: fluent.Colors.transparent,
            padding: const EdgeInsets.all(8),*/
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: ProgressRing())
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
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Inkommande samtal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(FluentIcons.chrome_close),
          onPressed: () {
            hidePopup();
          },
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Text(
        errorMessage!,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
         label:  'Namn',
         value:  contactInfo?['firstname'] ?? 'Okänd',
         icon:  FluentIcons.contact,
        ),
        _buildInfoRow(
          label: 'Mobil',
          value: widget.phoneNumber,
          icon: FluentIcons.phone,
        ),
        if (contactInfo?['email'] != null)
          _buildInfoRow(
            label: 'Email',
            value: contactInfo!['email'],
            icon: FluentIcons.mail,
          ),
        if (contactInfo?['company'] != null)
          _buildInfoRow(
           label:  'Företag',
           value:  contactInfo!['company'],
           icon:  FluentIcons.office_logo,
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
                  FluentIcons.status_circle_sync,
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

  Widget _buildInfoRow({String? label, String? value, IconData? icon}) {
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
              '$value: ',
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
      child: FilledButton(
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
