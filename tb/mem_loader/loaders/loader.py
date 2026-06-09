from abc import ABC, abstractmethod

class Loader(ABC):

    @abstractmethod
    async def write_row(self, addr: int, row_data: bytes):
        raise NotImplementedError(
            "write_row() must be implemented by subclasses of Loader"
        )

    @abstractmethod
    async def write_byte(self, addr: int, data: bytes):
        raise NotImplementedError(
            "write_byte() must be implemented by subclasses of Loader"
        )

    @abstractmethod
    async def read_byte(self, addr: int) -> bytes:
        raise NotImplementedError(
            "read_byte() must be implemented by subclasses of Loader"
        )

