
import 'dart:async';
import 'dart:math';

class LiveViewerService {
  // Por ahora, simularemos la entrada y salida de usuarios.
  
  Stream<int> get liveViewerStream async* {
    int currentViewers = 15234; // Número base
    final random = Random();
    
    while (true) {
      // Actualiza cada 2 a 5 segundos simulando tráfico real
      await Future.delayed(Duration(seconds: random.nextInt(3) + 2));
      
      // Simula que entran (hasta +15) o salen (hasta -5) personas
      int change = random.nextInt(20) - 5; 
      currentViewers += change;
      
      if (currentViewers < 0) currentViewers = 0;
      
      // Emite el nuevo valor a la interfaz
      yield currentViewers;
    }
  }
}