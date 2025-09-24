import '../models/notification_model.dart';

class NotificationConstants {
  // Notification IDs - PHẢI DUY NHẤT!
  static const int MORNING_GREETING = 1;
  static const int EVENING_REMINDER = 2;
  static const int LUNCH_BREAK = 3;
  static const int WORKOUT_TIME = 4;
  static const int MEDITATION_TIME = 5;
  
  // Channel IDs
  static const String DAILY_CHANNEL = 'daily_reminders';
  static const String HEALTH_CHANNEL = 'health_reminders';
  static const String WORK_CHANNEL = 'work_reminders';
  
  // Predefined notifications
  static List<NotificationModel> get defaultNotifications => [
    // Morning greeting - 7:30 AM
    NotificationModel(
      id: MORNING_GREETING,
      title: '🌅 Chào buổi sáng!',
      body: 'Hãy bắt đầu ngày mới với năng lượng tích cực! 💪',
      hour: 7,
      minute: 30,
      channelId: DAILY_CHANNEL,
      channelName: 'Daily Reminders',
    ),
    
    // Lunch break - 12:00 PM
    NotificationModel(
      id: LUNCH_BREAK,
      title: '🍽️ Giờ ăn trưa!',
      body: 'Đã đến giờ nghỉ trưa, hãy thưởng thức bữa ăn ngon! 😋',
      hour: 12,
      minute: 0,
      channelId: DAILY_CHANNEL,
      channelName: 'Daily Reminders',
    ),
    
    // Workout time - 6:00 PM
    NotificationModel(
      id: WORKOUT_TIME,
      title: '💪 Giờ tập thể dục!',
      body: 'Hãy dành 30 phút để chăm sóc sức khỏe của bạn! 🏃‍♂️',
      hour: 18,
      minute: 0,
      channelId: HEALTH_CHANNEL,
      channelName: 'Health Reminders',
    ),
    
    // Evening reminder - 9:00 PM
    NotificationModel(
      id: EVENING_REMINDER,
      title: '🌙 Chuẩn bị nghỉ ngơi',
      body: 'Hãy thư giãn và chuẩn bị cho giấc ngủ ngon! 😴',
      hour: 21,
      minute: 0,
      channelId: DAILY_CHANNEL,
      channelName: 'Daily Reminders',
    ),
    
    // Meditation time - 6:00 AM
    NotificationModel(
      id: MEDITATION_TIME,
      title: '🧘‍♂️ Thời gian thiền định',
      body: 'Dành 10 phút để tĩnh tâm và chuẩn bị tinh thần! ✨',
      hour: 6,
      minute: 0,
      channelId: HEALTH_CHANNEL,
      channelName: 'Health Reminders',
    ),
  ];
  
  // Helper method to get notification by ID
  static NotificationModel? getNotificationById(int id) {
    try {
      return defaultNotifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Helper method to get available ID for new notification
  static int getNextAvailableId() {
    final usedIds = defaultNotifications.map((n) => n.id).toList();
    int nextId = 10; // Start from 10 for custom notifications
    while (usedIds.contains(nextId)) {
      nextId++;
    }
    return nextId;
  }
}