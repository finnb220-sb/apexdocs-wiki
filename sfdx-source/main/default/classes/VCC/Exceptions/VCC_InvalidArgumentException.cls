/**
 * @description Intended to be thrown when an null, or otherwise invalid argument is passed to a method.
 * Used to 'fail fast', and guard against hard to debug problems.
 * Why wait for the null pointer when you could throw this puppy instead, and tell your future self EXACTLY what happened?
 */
public class VCC_InvalidArgumentException extends Exception {
}
