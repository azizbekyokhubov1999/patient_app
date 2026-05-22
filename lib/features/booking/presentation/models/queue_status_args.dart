/// Route arguments for [QueueStatusPage].
class QueueStatusArgs {
  const QueueStatusArgs({
    required this.appointmentId,
    this.roomNumber = 'Room 204',
    this.queueNumber = 3,
    this.estimatedWait = '~15 mins',
  });

  final String appointmentId;
  final String roomNumber;
  final int queueNumber;
  final String estimatedWait;
}
