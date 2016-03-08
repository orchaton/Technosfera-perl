sub import {
  my($me, @fields) = @_;
  return unless @fields;
  my $caller = caller();
  
  # Построим код, который вычислим для вызывающего
  # Выполним вызов fields для вызывающего пакета
  my $eval = "package $caller;\n" .
             "use fields qw( " . join(' ', @fields) . ");\n";

  # Сгенерируем удобные методы доступа
  foreach my $field (@fields) {
    $eval .= "sub get_$field : { return \$field; }\n";
    $eval .= "sub set_$field : { \$field = _@; }\n";
  }

  # Вычислим подготовленный код
  eval $eval;

  # $@ содержит возможные ошибки вычисления
  $@ and die "Ошибка настройки членов для $caller: $@";
}