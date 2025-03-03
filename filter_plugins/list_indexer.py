#!/usr/bin/python

class FilterModule(object):
    def filters(self):
        return {'list_indexer': self.list_indexer}

    def list_indexer(self, lst, indices):
        """Return items from lst at given indices (1-based)"""
        result = []
        for idx in indices:
            if idx > 0 and idx <= len(lst):
                result.append(lst[idx - 1])
        return result