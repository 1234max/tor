/* Copyright (c) 2008, The Tor Project, Inc. */
/* See LICENSE for licensing information */
/* $Id$ */
/* Tor dependencies */

#ifndef MEMAREA_H
#define MEMAREA_H

typedef struct memarea_t memarea_t;

memarea_t *memarea_new(size_t chunk_size);
void memarea_drop_all(memarea_t *area);
void memarea_clear(memarea_t *area);
int memarea_owns_ptr(const memarea_t *area, const void *ptr);
void *memarea_alloc(memarea_t *area, size_t sz);
void *memarea_alloc_zero(memarea_t *area, size_t sz);
void *memarea_memdup(memarea_t *area, const void *s, size_t n);
char *memarea_strdup(memarea_t *area, const char *s);
char *memarea_strndup(memarea_t *area, const char *s, size_t n);
void memarea_assert_ok(memarea_t *area);

#endif
