import 'dart:async';

import 'package:wire/wire.dart';
import 'dart:html';

import 'components/counter_button.dart';
import 'components/counter_display.dart';
import 'const/counter_params.dart';
import 'const/counter_signals.dart';

var processor;
var application;

main() {
  /// COUNTER EXAMPLE ======================================
  Wire.data(CounterParams.COUNT, 0);
  print('Init Ready: initial value = ' + Wire.data(CounterParams.COUNT).value.toString());
  init();
}

void init() {
  processor = Processor();
  application = Application(document.querySelector('#root'));
}

class Processor {
  Processor() {
    Wire.add(this, CounterSignal.INCREASE, ([opt]) {
      Wire.data(CounterParams.COUNT, (value) {
        print('> Processor: INCREASE -> handle: ' + value.toString());
        return value + 1;
      });
    });

    Wire.add(this, CounterSignal.DECREASE, ([opt]) {
      Wire.data(CounterParams.COUNT, (value) {
        print('> Processor: DECREASE -> handle: ' + value.toString());
        return value > 0 ? value - 1 : 0;
      });
    });

    print('Processor Ready');
  }
}

class Application {
  DivElement root;
  Application(this.root)
  {
    try {

      var group = DivElement()..className = 'spectrum-ButtonGroup';

      root.append(CounterDisplay().dom);
      group.append(CounterButton('Increase', CounterSignal.INCREASE).dom);
      group.append(CounterButton('Decrease', CounterSignal.DECREASE).dom);
      root.append(group);

    } catch(e) {
      print(e);
    }
  }
}