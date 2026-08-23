class ReservationItem {
  final String space;
  final String date;
  final String time;
  final String status;

  const ReservationItem({
    required this.space,
    required this.date,
    required this.time,
    required this.status,
  });

  bool get isApproved => status == 'Approved';
}
