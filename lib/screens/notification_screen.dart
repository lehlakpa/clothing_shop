import 'package:clothing_shop/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final savedNotifications = await NotificationService.getNotifications();

    if (!mounted) return;

    setState(() {
      notifications = savedNotifications;
      isLoading = false;
    });
  }

  Future<void> clearAll() async {
    await NotificationService.clearNotifications();

    if (!mounted) return;

    setState(() {
      notifications.clear();
    });
  }

  Future<void> deleteNotification(String id) async {
    await NotificationService.deleteNotification(id);

    await loadNotifications();
  }

  String formatTime(String? time) {
    if (time == null) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(time);

      final hour = dateTime.hour;

      final minute = dateTime.minute.toString().padLeft(2, '0');

      final period = hour >= 12 ? 'PM' : 'AM';

      final displayHour = hour == 0
          ? 12
          : hour > 12
          ? hour - 12
          : hour;

      return '$displayHour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,

        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Clear notifications?'),
                      content: const Text(
                        'All saved notifications will be deleted.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            await clearAll();
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const _EmptyNotificationView()
          : RefreshIndicator(
              onRefresh: loadNotifications,

              child: ListView.builder(
                padding: const EdgeInsets.all(12),

                itemCount: notifications.length,

                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  final title = notification['title'] ?? 'Notification';

                  final body = notification['body'] ?? '';

                  final time = notification['time'];

                  final id = notification['id'] ?? index.toString();

                  return Dismissible(
                    key: ValueKey(id),

                    direction: DismissDirection.endToStart,

                    background: Container(
                      margin: const EdgeInsets.only(bottom: 10),

                      padding: const EdgeInsets.only(right: 20),

                      alignment: Alignment.centerRight,

                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(Icons.delete, color: Colors.white),
                    ),

                    onDismissed: (_) {
                      deleteNotification(id);
                    },

                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),

                      elevation: 2,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: const CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.notifications),
                        ),

                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),

                          child: Text(
                            body,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                        trailing: Text(
                          formatTime(time),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _EmptyNotificationView extends StatelessWidget {
  const _EmptyNotificationView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.notifications_none, size: 90, color: Colors.grey.shade400),

          const SizedBox(height: 15),

          const Text(
            'No notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 8),

          Text(
            'Your notifications will appear here.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
