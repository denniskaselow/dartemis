/**
 * A tag class. All components in the system must extend this class.
 *
 * @author Arni Arent
 */
abstract class Component {

  // TODO remove when this is implemented http://news.dartlang.org/2012/06/proposal-for-first-class-types-in-dart.html
  abstract Type get type();
}