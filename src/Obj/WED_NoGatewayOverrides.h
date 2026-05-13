/*
 * Second forced-include (after XDefs.h) when CMake WED_NO_GATEWAY=ON.
 * Disables Gateway *export* / submit / upload only. Import from Gateway stays on (HAS_GATEWAY).
 */
#undef HAS_GATEWAY_EXPORT
#define HAS_GATEWAY_EXPORT 0
