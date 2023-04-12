abstract class AlertEvent{}

class InitAlerts extends AlertEvent{

   final bool fromMemory;
   InitAlerts({required this.fromMemory});

}