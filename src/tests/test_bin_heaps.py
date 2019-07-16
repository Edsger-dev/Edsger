from edsger.test_heaps import (
    bheap_init,
    bheap_insert_01,
    bheap_insert_02,
    bheap_insert_03,
    bheab_decrease,
    bheap_peek,
    bheap_is_empty,
    bheap_extract,
    sort,
)


def test_bheap_init_01():
    assert bheap_init(0)


def test_bheap_init_02():
    assert bheap_init(4)


def test_bheap_insert_01():
    assert bheap_insert_01()


def test_bheap_insert_02():
    assert bheap_insert_02()


def test_bheap_insert_03():
    assert bheap_insert_03()


def test_bheab_decrease():
    assert bheab_decrease()


def test_bheap_peek():
    assert bheap_peek()


def test_bheap_is_empty():
    assert bheap_is_empty()


def test_bheap_extract():
    assert bheap_extract()


def test_sort():
    assert sort()
