#ifndef XV6_BENCHSTATS_H
#define XV6_BENCHSTATS_H
// Include types.h before this header.
struct benchstats {
  uint64 instruction_faults;
  uint64 load_faults;
  uint64 store_faults;
  uint64 pages_mapped;
  uint64 pages_freed;
  uint64 resident_pages;
  uint64 virtual_bytes;
  uint64 ticks;
};
#endif
