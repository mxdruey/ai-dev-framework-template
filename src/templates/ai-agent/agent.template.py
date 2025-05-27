"""
AI Agent Template

This template provides a foundation for building AI agents
with tool integration, memory management, and safety features.
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass, field
from enum import Enum
import uuid

from langchain.memory import ConversationBufferMemory
from langchain.tools import Tool
from langchain.schema import BaseMessage, HumanMessage, AIMessage


class MessageType(Enum):
    """Types of messages agents can send/receive"""
    REQUEST = "request"
    RESPONSE = "response"
    ERROR = "error"
    NOTIFICATION = "notification"


class Priority(Enum):
    """Message priority levels"""
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    CRITICAL = 4


@dataclass
class AgentMessage:
    """Standard message format for agent communication"""
    sender_id: str
    receiver_id: str
    message_type: MessageType
    content: Dict[str, Any]
    timestamp: datetime = field(default_factory=datetime.now)
    correlation_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    priority: Priority = Priority.MEDIUM


@dataclass
class AgentConfig:
    """Configuration for AI agents"""
    agent_id: str
    name: str
    description: str
    model_name: str = "gpt-4"
    temperature: float = 0.7
    max_tokens: int = 2000
    tools: List[Tool] = field(default_factory=list)
    safety_enabled: bool = True
    memory_enabled: bool = True
    max_retries: int = 3


class SafetyWrapper:
    """Safety wrapper for agent inputs and outputs"""
    
    def __init__(self, rules: Optional[Dict[str, Any]] = None):
        self.rules = rules or self._default_rules()
        self.logger = logging.getLogger(f"{__name__}.SafetyWrapper")
    
    def _default_rules(self) -> Dict[str, Any]:
        return {
            "max_output_length": 10000,
            "forbidden_patterns": [],
            "require_human_approval": False,
            "rate_limit": 100,  # requests per minute
        }
    
    async def validate_input(self, message: AgentMessage) -> bool:
        """Validate incoming message"""
        # Implement input validation logic
        return True
    
    async def validate_output(self, response: Any) -> bool:
        """Validate agent output before sending"""
        # Implement output validation logic
        return True


class BaseAgent:
    """Base AI Agent with core functionality"""
    
    def __init__(self, config: AgentConfig):
        self.config = config
        self.agent_id = config.agent_id
        self.logger = logging.getLogger(f"{__name__}.{config.name}")
        
        # Initialize components
        self.memory = self._init_memory() if config.memory_enabled else None
        self.safety_wrapper = SafetyWrapper() if config.safety_enabled else None
        self.tools = self._init_tools(config.tools)
        self.message_queue: asyncio.Queue = asyncio.Queue()
        
        # State management
        self.is_running = False
        self.current_task = None
        
    def _init_memory(self) -> ConversationBufferMemory:
        """Initialize agent memory"""
        return ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True
        )
    
    def _init_tools(self, tools: List[Tool]) -> Dict[str, Tool]:
        """Initialize tools available to the agent"""
        return {tool.name: tool for tool in tools}
    
    async def start(self):
        """Start the agent"""
        self.is_running = True
        self.logger.info(f"Agent {self.agent_id} started")
        
        # Start message processing loop
        asyncio.create_task(self._process_messages())
    
    async def stop(self):
        """Stop the agent"""
        self.is_running = False
        self.logger.info(f"Agent {self.agent_id} stopped")
    
    async def _process_messages(self):
        """Main message processing loop"""
        while self.is_running:
            try:
                # Get message from queue with timeout
                message = await asyncio.wait_for(
                    self.message_queue.get(),
                    timeout=1.0
                )
                
                # Process message
                await self.process_message(message)
                
            except asyncio.TimeoutError:
                continue
            except Exception as e:
                self.logger.error(f"Error processing message: {e}")
    
    async def process_message(self, message: AgentMessage) -> Optional[AgentMessage]:
        """Process incoming message"""
        try:
            # Validate input
            if self.safety_wrapper:
                if not await self.safety_wrapper.validate_input(message):
                    raise ValueError("Message failed safety validation")
            
            # Store in memory if enabled
            if self.memory:
                self.memory.chat_memory.add_message(
                    HumanMessage(content=str(message.content))
                )
            
            # Process message based on type
            if message.message_type == MessageType.REQUEST:
                response = await self._handle_request(message)
            elif message.message_type == MessageType.NOTIFICATION:
                response = await self._handle_notification(message)
            else:
                response = None
            
            # Validate output
            if response and self.safety_wrapper:
                if not await self.safety_wrapper.validate_output(response):
                    raise ValueError("Response failed safety validation")
            
            # Store response in memory
            if response and self.memory:
                self.memory.chat_memory.add_message(
                    AIMessage(content=str(response.content))
                )
            
            return response
            
        except Exception as e:
            self.logger.error(f"Error processing message: {e}")
            return self._create_error_response(message, str(e))
    
    async def _handle_request(self, message: AgentMessage) -> AgentMessage:
        """Handle request messages"""
        # Override in subclasses
        raise NotImplementedError
    
    async def _handle_notification(self, message: AgentMessage) -> Optional[AgentMessage]:
        """Handle notification messages"""
        # Override in subclasses if needed
        self.logger.info(f"Received notification: {message.content}")
        return None
    
    def _create_error_response(self, original_message: AgentMessage, error: str) -> AgentMessage:
        """Create error response message"""
        return AgentMessage(
            sender_id=self.agent_id,
            receiver_id=original_message.sender_id,
            message_type=MessageType.ERROR,
            content={"error": error, "original_message_id": original_message.correlation_id},
            correlation_id=original_message.correlation_id
        )
    
    async def send_message(self, message: AgentMessage):
        """Send message to another agent or system"""
        # Implement message sending logic
        self.logger.info(f"Sending message: {message}")
    
    async def use_tool(self, tool_name: str, **kwargs) -> Any:
        """Use a registered tool"""
        if tool_name not in self.tools:
            raise ValueError(f"Tool {tool_name} not found")
        
        tool = self.tools[tool_name]
        try:
            result = await tool.arun(**kwargs) if hasattr(tool, 'arun') else tool.run(**kwargs)
            self.logger.info(f"Tool {tool_name} executed successfully")
            return result
        except Exception as e:
            self.logger.error(f"Error executing tool {tool_name}: {e}")
            raise


class SpecializedAgent(BaseAgent):
    """Example specialized agent implementation"""
    
    async def _handle_request(self, message: AgentMessage) -> AgentMessage:
        """Handle incoming requests"""
        request_type = message.content.get("type")
        
        if request_type == "analyze":
            result = await self._analyze_data(message.content.get("data"))
        elif request_type == "search":
            result = await self._perform_search(message.content.get("query"))
        else:
            result = {"error": f"Unknown request type: {request_type}"}
        
        return AgentMessage(
            sender_id=self.agent_id,
            receiver_id=message.sender_id,
            message_type=MessageType.RESPONSE,
            content=result,
            correlation_id=message.correlation_id
        )
    
    async def _analyze_data(self, data: Any) -> Dict[str, Any]:
        """Analyze provided data"""
        # Implement analysis logic
        return {"analysis": "completed", "results": {}}
    
    async def _perform_search(self, query: str) -> Dict[str, Any]:
        """Perform search operation"""
        # Use search tool if available
        if "search" in self.tools:
            results = await self.use_tool("search", query=query)
            return {"search_results": results}
        return {"error": "Search tool not available"}


# Example usage
if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)
    
    # Create agent configuration
    config = AgentConfig(
        agent_id="agent-001",
        name="ResearchAgent",
        description="Agent for research and analysis",
        tools=[
            # Add your tools here
        ]
    )
    
    # Create and start agent
    agent = SpecializedAgent(config)
    
    # Run agent
    async def main():
        await agent.start()
        
        # Example: Send a message to the agent
        test_message = AgentMessage(
            sender_id="user-001",
            receiver_id="agent-001",
            message_type=MessageType.REQUEST,
            content={"type": "analyze", "data": {"sample": "data"}}
        )
        
        await agent.message_queue.put(test_message)
        
        # Keep agent running
        await asyncio.sleep(10)
        
        # Stop agent
        await agent.stop()
    
    # Run the example
    asyncio.run(main())