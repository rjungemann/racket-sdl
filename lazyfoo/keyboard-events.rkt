#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define
         "../sdl/main.rkt")

(define _SDL_KEYDOWN #x300)
(define _SDL_EVENT_TYPE_OFFSET 0)
(define _SDL_KEYBOARDEVENT_OFFSET 3)

(module* main #f
  (SDL_Init SDL_INIT_EVERYTHING)
  (let* ([window (SDL_CreateWindow "Foo"
                                   SDL_WINDOWPOS_CENTERED
                                   SDL_WINDOWPOS_CENTERED
                                   640
                                   480
                                   SDL_WINDOW_SHOWN)]
         [surface (SDL_GetWindowSurface window)]
         [event-ptr (malloc (ctype-sizeof _SDL_Event*))]
         [event (cast event-ptr _pointer _SDL_Event*)])
    (let loop ()
      (let check-events ()
        (when (> (SDL_PollEvent event) 0)
          (let* ([event-ref (ptr-ref event _SDL_Event 0)]
                 [type (union-ref event-ref _SDL_EVENT_TYPE_OFFSET)])
            (when (equal? type _SDL_KEYDOWN)
              (let* ([keyboard-event (union-ref event-ref _SDL_KEYBOARDEVENT_OFFSET)]
                     [sym (SDL_Keysym-sym (SDL_KeyboardEvent-keysym keyboard-event))])
                (printf "pressed ~s\n" sym)))
            (check-events))))
      (SDL_Delay 20)
      (loop))))
